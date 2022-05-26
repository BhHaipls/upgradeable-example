// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./management/ManagedUpgradeable.sol";
import "./interfaces/IKRUShopsPool.sol";
import "./interfaces/IKRUShopsManager.sol";

/// @title KRUShopsPool
/// @author Applicature
/// @notice This contract is used to get funds from PaymentProccesor, transfer it to vendor removing fee amount
/// @dev Only registered contracts and shops can use KRUShopsPool's functions
contract KRUShopsPool is IKRUShopsPool, EIP712Upgradeable, ManagedUpgradeable {
    using AddressUpgradeable for address payable;
    /// @notice Store period duration in seconds to each cooldown type
    mapping(Cooldown => uint256) public override cooldownPeriods;

    /// @notice Store withdrawal info of shops
    mapping(address => WithdrawalInfo) public override withdrawalData;

    /// @notice Store shops' order balances
    mapping(address => uint256) public override balanceOf;

    /// @notice Store hash to sign withdraw to compromised shop
    /// @dev Store computed 256 bit keccak hash
    bytes32 private constant _CONTAINER_TYPEHASE =
        keccak256("Container(address sender,address recipient,uint256 amount,uint256 deadline,uint256 nonce)");

    /// @notice Store nonces of compromised withdraws
    /// @dev Store compromised withdraws nonces to sign transactions
    mapping(address => mapping(uint256 => bool)) internal _nonces;

    /// @notice Сhecks whether the sender can withdraw funds to executing the function
    /// @dev Сhecks whether shop is registered, not frozen or blacklisted
    /// @param shop_ Address of the shop
    modifier canWithdraw(address shop_) {
        require(
            IKRUShopsManager(management.contractRegistry(CONTRACT_KRU_SHOPS_MANAGER)).isRegistered(shop_),
            ERROR_IS_NOT_EXISTS
        );
        require(
            !(_hasPermission(shop_, SHOPS_MANAGER_BLACK_LIST_PERM) ||
                _hasPermission(shop_, SHOPS_MANAGER_FREEZE_LIST_PERM)),
            ERROR_NOT_AVAILABLE
        );
        _;
    }

    /// @notice Initializes the address of management and cooldown periods
    /// @dev Initializes the address of management and cooldown periods
    /// @param managementAddress_ the address of management
    function initialize(address managementAddress_) external virtual initializer {
        cooldownPeriods[Cooldown.Daily] = 1 days;
        cooldownPeriods[Cooldown.Weekly] = 7 days;
        cooldownPeriods[Cooldown.Monthly] = 30 days;

        __Managed_init(managementAddress_);
        __EIP712_init("KRUShopsPool", "v1");
    }

    /// @notice Transfer some KRU to shop order balance
    /// @dev Emit event with shop address and transfered KRU amount
    /// @param shop_ Address of the shop
    function orderIn(address shop_)
        external
        payable
        virtual
        override
        canCallOnlyRegisteredContract(CONTRACT_KRU_SHOPS_PAYMENT_PROCCESOR)
    {
        balanceOf[shop_] += msg.value;
        emit Paid(shop_, msg.value);
    }

    /// @notice Set withdrawal cooldown to shop
    /// @dev If none is selected BE cannot withdraw funds to shop
    /// @param cooldown_ Selected withdrawal cooldown
    function setWithdrawalCooldown(Cooldown cooldown_) external virtual override canWithdraw(_msgSender()) {
        require(withdrawalData[_msgSender()].cooldown != cooldown_, ERROR_IS_SET);
        withdrawalData[_msgSender()].cooldown = cooldown_;
        emit SetWithdrawalCooldown(_msgSender(), cooldown_);
    }

    /// @notice Withdraw all available shop funds and transfer fee
    /// @dev Emit event with transfered calculated funds and fee
    function withdraw() external virtual override canWithdraw(_msgSender()) {
        (uint256 availToWithdraw, uint256 fee) = _calculateAvailWithdrawal(_msgSender(), 0);
        require(availToWithdraw > 0, ERROR_AMOUNT_IS_ZERO);
        balanceOf[_msgSender()] = 0;

        payable(_msgSender()).sendValue(availToWithdraw);
        payable(management.contractRegistry(CONTRACT_KRU_SHOPS_TRESUARY)).sendValue(fee);

        emit Withdrawn(_msgSender(), availToWithdraw, fee);
    }

    /// @notice Withdraw all available shop funds and transfer fee
    /// @dev Function will be called from BE side
    /// @param shop_ Address of shop that will get funds
    function withdrawFor(address shop_)
        external
        virtual
        override
        requirePermission(SHOPS_POOL_CAN_WITHDRAW_FOR)
        canWithdraw(shop_)
    {
        uint256 gasBefore = gasleft();
        WithdrawalInfo memory info = withdrawalData[shop_];

        require(info.cooldown != Cooldown.None, ERROR_NOT_AVAILABLE);
        require(block.timestamp > info.lastWithdraw + cooldownPeriods[info.cooldown], ERROR_COOLDOWN_IS_NOT_OVER);

        (uint256 availToWithdraw, uint256 fee) = _calculateAvailWithdrawal(shop_, 0);
        require(availToWithdraw > 0, ERROR_AMOUNT_IS_ZERO);

        withdrawalData[shop_].lastWithdraw = block.timestamp;
        balanceOf[shop_] = 0;

        payable(management.contractRegistry(CONTRACT_KRU_SHOPS_TRESUARY)).sendValue(fee);

        uint256 beFee = tx.gasprice * (gasBefore - gasleft() + 84000);

        availToWithdraw -= beFee;

        payable(shop_).sendValue(availToWithdraw);
        payable(_msgSender()).sendValue(beFee);

        emit WithdrawnFor(_msgSender(), shop_, availToWithdraw, fee, beFee);
    }

    /// @notice Withdraw some amount of funds from compromised shop to recipient by shop signature
    /// @dev Expire date, signature, nonce and amount will be checked by EIP712
    /// @param recipient_ Address that get funds after withdraw
    /// @param amount_ Selected amount to withdraw
    /// @param deadline_ Expire date of withdraw
    /// @param nonce_ Nonce of withdraw
    /// @param v_ Signature parameter
    /// @param r_ Signature parameter
    /// @param s_ Signature parameter
    function withdrawFromCompromised(
        address recipient_,
        uint256 amount_,
        uint256 deadline_,
        uint256 nonce_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external virtual override requirePermission(SHOPS_POOL_CAN_WITHDRAW_COMPROMISED_FUNDS) {
        require(deadline_ > block.timestamp, ERROR_TIME_OUT);

        address shop = _getCompromisedShop(_msgSender(), recipient_, amount_, deadline_, nonce_, v_, r_, s_);

        require(!_nonces[shop][nonce_], ERROR_INVALID_NONCE);
        _nonces[shop][nonce_] = true;

        (uint256 availToWithdraw, uint256 fee) = _calculateAvailWithdrawal(shop, amount_);
        require(availToWithdraw > 0, ERROR_AMOUNT_IS_ZERO);

        balanceOf[shop] -= (availToWithdraw + fee);

        payable(management.contractRegistry(CONTRACT_KRU_SHOPS_TRESUARY)).sendValue(fee);
        payable(recipient_).sendValue(availToWithdraw);

        emit WithdrawFromCompromised(_msgSender(), shop, recipient_, availToWithdraw, fee);
    }

    /// @notice Calculates all available shop funds and fee to transfer
    /// @dev Calculates avail fee and funds with fee percentage from manager
    /// @param shop_ the address of shop
    /// @return Returns all available shop funds and fee
    function _calculateAvailWithdrawal(address shop_, uint256 amount_)
        internal
        view
        virtual
        returns (uint256, uint256)
    {
        uint256 balance = balanceOf[shop_];
        if (balance > 0 && balance >= amount_) {
            uint256 amount = amount_ > 0 ? amount_ : balance;
            uint256 feePercentage = IKRUShopsManager(management.contractRegistry(CONTRACT_KRU_SHOPS_MANAGER))
                .getCommission(shop_);
            uint256 fee = (amount * feePercentage) / PERCENTAGE_100;
            return (amount - fee, fee);
        }
        return (0, 0);
    }

    /// @notice Extract compromised shop
    /// @dev Return shop address from signature if it's compromised
    /// @param sender_ Transaction sender
    /// @param recipient_ Address that get funds after withdraw
    /// @param amount_ Selected amount to withdraw
    /// @param deadline_ Expire date of withdraw
    /// @param nonce_ Nonce of withdraw
    /// @param v_ Signature parameter
    /// @param r_ Signature parameter
    /// @param s_ Signature parameter
    /// @return Shop address
    function _getCompromisedShop(
        address sender_,
        address recipient_,
        uint256 amount_,
        uint256 deadline_,
        uint256 nonce_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) internal view virtual returns (address) {
        bytes32 structHash = keccak256(
            abi.encode(_CONTAINER_TYPEHASE, sender_, recipient_, amount_, deadline_, nonce_)
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address messageShop = ECDSAUpgradeable.recover(hash, v_, r_, s_);

        require(
            _hasPermission(messageShop, SHOPS_MANAGER_BLACK_LIST_PERM) ||
                _hasPermission(messageShop, SHOPS_MANAGER_FREEZE_LIST_PERM),
            ERROR_NOT_COMPROMISED
        );

        return messageShop;
    }
}
