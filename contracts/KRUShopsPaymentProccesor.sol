// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IKRUShopsPaymentProccesor.sol";
import "./interfaces/IKRUShopsManager.sol";
import "./interfaces/IKRUShopsPool.sol";
import "./management/ManagedUpgradeable.sol";

/// @title KRUShopsPaymentProccesor
/// @author Applicature
/// @notice This contract is used to accept payments of KRU in shops and transfer it to KRU Pool
/// @dev KRUShopsPaymentProccesor can accept shop payments & transfer it to pool and add/remove payment signers
contract KRUShopsPaymentProccesor is IKRUShopsPaymentProccesor, EIP712Upgradeable, ManagedUpgradeable {
    using AddressUpgradeable for address payable;

    /// @notice Store bool whether manual rate is active
    /// @dev If true uniswap rate will be not calculated
    /// @return Boolean value (true/false)
    bool public override isManualMode;

    /// @notice Store bool whether state is paused
    /// @dev If true will block new orders payment
    /// @return Boolean value (true/false)
    bool public override isPaused;

    /// @notice Store number of manual rate
    /// @dev Store how many USDK KRU costs
    /// @return Number in KRU
    uint256 public override rate;

    /// @notice Store bool whether order is paid
    /// @dev Unpaid orders have false value
    /// @return Bool whether order is paid
    mapping(string => bool) public override paidOrders;

    /// @notice Store hash to sign payment transaction
    /// @dev Store computed 256 bit keccak hash
    bytes32 private constant _CONTAINER_TYPEHASE =
        keccak256("Container(string orderId,address shop,address sender,uint256 usdAmount,uint256 deadline)");

    /// @notice Initializes the address of management
    /// @dev Initializes the address of management
    /// @param management_ the address of management
    function initialize(address management_) external virtual initializer {
        __Managed_init(management_);
        __EIP712_init("KRUShopsPaymentProccesor", "v1");
    }

    /// @notice Update rate value
    /// @dev If setted can be used in KRU calculation
    /// @param rate_ New rate
    function setRate(uint256 rate_) external virtual override requirePermission(SHOPS_PAYMENT_CAN_SET_RATE) {
        require(rate_ > 0, ERROR_AMOUNT_IS_ZERO);
        rate = rate_;
        emit RateSetted(rate_);
    }

    /// @notice Change whether manual rate is active
    /// @dev If true can be used in KRU calculation
    function switchMode() external virtual override requirePermission(SHOPS_PAYMENT_CAN_SWITCH_MODE) {
        isManualMode = !isManualMode;
        emit ModeSwitched(isManualMode);
    }

    /// @notice Change whether state is paused
    /// @dev If true will block new orders payment
    /// @param pause_ whether state is paused
    function setPause(bool pause_) external virtual override requirePermission(SHOPS_PAYMENT_CAN_SWITCH_STATE) {
        isPaused = pause_;
        emit SetPause(pause_);
    }

    /// @notice Pay to new order and transfer funds to KRUShopsPool
    /// @dev Expire date, signature, unice of orderId will be checked by EIP712
    /// @param orderId_ Id of order in UUID v4
    /// @param shopAddress_ Shop address registered in Manager
    /// @param usdAmount_ Order price in USD
    /// @param deadline_ Expire date of order
    /// @param v_ Signature parameter
    /// @param r_ Signature parameter
    /// @param s_ Signature parameter
    function pay(
        string memory orderId_,
        address shopAddress_,
        uint256 usdAmount_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external payable virtual override {
        require(!isPaused, ERROR_CONTRACT_IS_PAUSED);
        require(!paidOrders[orderId_], ERROR_ALREADY_PAID);
        require(usdAmount_ > 0, ERROR_AMOUNT_IS_ZERO);

        uint256 requiredKRU = _getEstimatedKRU(usdAmount_);
        require(msg.value >= requiredKRU, ERROR_INSUFFICIENT_AMOUNT);

        require(deadline_ > block.timestamp, ERROR_TIME_OUT);
        require(
            _isValidSigner(orderId_, shopAddress_, _msgSender(), usdAmount_, deadline_, v_, r_, s_),
            ERROR_INVALID_SIGNER
        );

        IKRUShopsManager(management.contractRegistry(CONTRACT_KRU_SHOPS_MANAGER)).checkPaymentShop(shopAddress_);

        paidOrders[orderId_] = true;

        IKRUShopsPool(management.contractRegistry(CONTRACT_KRU_SHOPS_POOL)).orderIn{value: requiredKRU}(shopAddress_);

        if (requiredKRU != msg.value) payable(_msgSender()).sendValue(msg.value - requiredKRU);

        emit Payment(orderId_, _msgSender(), shopAddress_, usdAmount_, requiredKRU);
    }

    /// @notice Get converted USD to KRU by current price
    /// @param estimatedUSD_ Required USD amount
    /// @return Required KRU amount
    function getEstimatedKRU(uint256 estimatedUSD_) external view virtual override returns (uint256) {
        return _getEstimatedKRU(estimatedUSD_);
    }

    /// @notice Define if signer is validate
    /// @dev Define if recipient's signature is validate
    /// @param sender_ Address of recipient
    /// @param usdAmount_ Amount of USD
    /// @param deadline_ Expire date of order
    /// @param v_ Signature parameter
    /// @param r_ Signature parameter
    /// @param s_ Signature parameter
    /// @return Bool whether signer is valid
    function _isValidSigner(
        string memory orderId_,
        address shopAddress_,
        address sender_,
        uint256 usdAmount_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) internal view virtual returns (bool) {
        bytes32 structHash = keccak256(
            abi.encode(_CONTAINER_TYPEHASE, keccak256(bytes(orderId_)), shopAddress_, sender_, usdAmount_, deadline_)
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address messageSigner = ECDSAUpgradeable.recover(hash, v_, r_, s_);
        return _hasPermission(messageSigner, SHOPS_PAYMENT_PAY_SIGNER);
    }

    /// @notice Get converted USD to KRU by current price
    /// @param estimatedUSD_ Required USD amount
    /// @return Required KRU amount
    function _getEstimatedKRU(uint256 estimatedUSD_) internal view virtual returns (uint256) {
        if (isManualMode) return (rate * estimatedUSD_) / DECIMALS18;

        IUniswapV2Pair pair = IUniswapV2Pair(management.contractRegistry(CONTRACT_UNISWAP_V2_PAIR));
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();

        require(reserve0 > 0 && reserve1 > 0, ERROR_RESERVES_IS_ZERO);

        return
            pair.token0() == management.contractRegistry(CONTRACT_WRAPPED_KRU)
                ? (estimatedUSD_ * reserve0) / reserve1
                : (estimatedUSD_ * reserve1) / reserve0;
    }
}
