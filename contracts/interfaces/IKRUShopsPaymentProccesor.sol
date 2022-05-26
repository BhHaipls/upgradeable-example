// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/// @title IKRUShopsPaymentProccesor
/// @author Applicature
/// @notice There is an interface to IKRUShopsPaymentProccesor contract that is used to accept payments of KRU
/// in shops and transfer it to KRU Pool
/// @dev KRUShopsPaymentProccesor can accept shop payments & transfer it to pool and add/remove payment signers
interface IKRUShopsPaymentProccesor {
    /// @notice Generated when user with SHOPS_PAYMENT_CAN_SET_RATE permission sets new KRU rate
    /// @param rate New rate number
    event RateSetted(uint256 rate);

    /// @notice Generated when user with SHOPS_PAYMENT_CAN_SWITCH_RATE permission switches rate mode
    /// @param isManualMode Boolean value whether manual rate is active
    event ModeSwitched(bool isManualMode);

    /// @notice Generated when user with SHOPS_PAYMENT_CAN_SWITCH_STATE permission switches state of contract
    /// @param isPaused Boolean value whether state is paused
    event SetPause(bool isPaused);

    /// @notice Generated when user pays amount of  KRU for the orderId in the shop
    /// @param orderId Id of order in UUID v4
    /// @param user Address of recipient
    /// @param shop Shop address registered in Manager
    /// @param usdAmount USD amount
    /// @param kruActualPaymentAmount Converted USD amount to KRU with current USD price
    event Payment(string orderId, address user, address shop, uint256 usdAmount, uint256 kruActualPaymentAmount);

    /// @notice Update rate value
    /// @dev If setted can be used in KRU calculation
    /// @param rate_ New rate
    function setRate(uint256 rate_) external;

    /// @notice Change whether manual rate is active
    /// @dev If true can be used in KRU calculation
    function switchMode() external;

    /// @notice Change whether state is paused
    /// @dev If true will block new orders payment
    /// @param pause_ whether state is paused
    function setPause(bool pause_) external;

    /// @notice Pay to new order and transfer funds to KRUShopsPool
    /// @dev Expire date, signature, unice of orderId will be checked by EIP712
    /// @param orderId_ Id of order in UUID v4
    /// @param shopAddress_ Shop address registered in Manager
    /// @param deadline_ Expire date of order
    /// @param usdAmount_ Order price in USD
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
    ) external payable;

    /// @notice Return bool whether manual rate is active
    /// @return Boolean value (true/false)
    function isManualMode() external view returns (bool);

    /// @notice Store bool whether state is paused
    /// @return Boolean value (true/false)
    function isPaused() external view returns (bool);

    /// @notice Return number of manual rate
    /// @return Number in KRU
    function rate() external view returns (uint256);

    /// @notice Store bool whether order is paid
    /// @dev Unpaid orders have false value
    /// @param orderId_ order which need check
    /// @return Bool whether order is paid
    function paidOrders(string calldata orderId_) external view returns (bool);

    /// @notice Get estimated KRU from USD amount
    /// @dev Get KRU amount how many KRU USDK costs by current rate
    /// @param estimatedUSD_ Required USD amount
    /// @return Required KRU amount
    function getEstimatedKRU(uint256 estimatedUSD_) external view returns (uint256);
}
