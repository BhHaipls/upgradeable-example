// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/// @title IKRUShopsPool
/// @author Applicature
/// @notice There is an interface to KRUShopsPool contract that is used to store
/// and transfer funds to shop removing fee amount
/// @dev Only registered contracts and shops can use KRUShopsPool's functions
interface IKRUShopsPool {
    /// @notice Enumeration of withdrawal cooldown modes
    /// @dev If none is selected BE cannot withdraw funds for shop
    enum Cooldown {
        None,
        Daily,
        Weekly,
        Monthly
    }

    /// @notice Structured data type for variables that store information about shop withdrawals
    /// @param cooldown Withdrawal cooldown mode to shop
    /// @param lastWithdraw Date of last shop withdrawal
    struct WithdrawalInfo {
        Cooldown cooldown;
        uint256 lastWithdraw;
    }

    /// @notice Generated when PaymentProccesor transfers order payment amount from sender to shop
    /// @param shop Shop address
    /// @param amount Amount of transfered KRU
    event Paid(address indexed shop, uint256 amount);

    /// @notice Generated when shop sets withdrawal cooldown to itself
    /// @param shop Address of the shop
    /// @param cooldown Selected withdrawal cooldown
    event SetWithdrawalCooldown(address indexed shop, Cooldown cooldown);

    /// @notice Generated when shop withdraws funds amount without fee that will be transfer to tresuary wallet
    /// @param shop Shop address
    /// @param amount Amount of transfered funds to shop
    /// @param fee Amount of transfered fee to tresuary
    event Withdrawn(address indexed shop, uint256 amount, uint256 fee);

    /// @notice Generated when multivest BE member withdraws funds amount for shop
    /// without fee that will be transfer to tresuary wallet
    /// @param shop Shop address
    /// @param amount Amount of transfered funds to shop
    /// @param fee Amount of transfered fee to tresuary
    /// @param beFee Amount of transfered fee to BE address
    event WithdrawnFor(address indexed sender, address indexed shop, uint256 amount, uint256 fee, uint256 beFee);

    /// @notice Generated when admin withdraws funds from compromised shop to recipient by shop signature
    /// @param sender Address of sender
    /// @param shop Address of shop
    /// @param recipient Address of recipient (can be shop)
    /// @param amount Selected amount to withdraw
    /// @param fee Amount of transfered fee to tresuary
    event WithdrawFromCompromised(
        address indexed sender,
        address indexed shop,
        address indexed recipient,
        uint256 amount,
        uint256 fee
    );

    /// @notice Transfer some KRU to shop order balance
    /// @dev Emit event with shop address and transfered KRU amount
    /// @param shop_ Address of the shop
    function orderIn(address shop_) external payable;

    /// @notice Set withdrawal cooldown to itself
    /// @dev If none is selected BE cannot withdraw funds to shop
    /// @param cooldown_ Selected withdrawal cooldown
    function setWithdrawalCooldown(Cooldown cooldown_) external;

    /// @notice Withdraw all available shop funds and transfer fee
    /// @dev Emit event with transfered calculated funds and fee
    function withdraw() external;

    /// @notice Withdraw all available shop funds and transfer fee
    /// @dev Function will be called from BE side
    /// @param shop_ Address of shop that will get funds
    function withdrawFor(address shop_) external;

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
    ) external;

    /// @notice Returns KRU balance of the shop
    /// @dev Returns value from shop balance mapping
    /// @param shop_ The address of shop
    /// @return KRU value
    function balanceOf(address shop_) external view returns (uint256);

    /// @notice Returns cooldown periods by cooldown type
    /// @dev Returns value from cooldownPeriods mapping
    /// @param cooldown_ The type of cooldown
    /// @return seconds how much cooldown duration
    function cooldownPeriods(Cooldown cooldown_) external view returns (uint256);

    /// @notice Returns info about shop cooldown type and last withdraw
    /// @dev Returns value from withdrawalData mapping
    /// @param shop_ The address of shop
    /// @return cooldown information about cooldown type
    /// @return lastWithdraw unix timestmap when last withdraw was done
    function withdrawalData(address shop_) external view returns (Cooldown cooldown, uint256 lastWithdraw);
}
