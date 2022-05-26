// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./management/ManagedUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./interfaces/IKRUShopsManager.sol";

/// @title KRUShopsManager
/// @author Applicature
/// @notice This Smart Contract is used for register the shops, add shop to BlackList, FreezeList and set up a fee
/// @dev This Smart Contract is used for register the shops, add shop to BlackList, FreezeList and set up a fee
contract KRUShopsManager is IKRUShopsManager, ManagedUpgradeable {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    /// @notice Store the delay time for commission changing
    uint256 public constant DELAY_TIME = 1 hours;

    /// @notice Store the max commision for shops
    uint256 public constant MAX_COMMISION = 10 * PERCENTAGE_1;

    /// @notice Store automatic or manual register mode
    /// @dev Store automatic or manual register mode
    RegisterMode public override registerMode;

    /// @notice Store specific commission values for some shops
    /// @dev Store specific commission values for some shops
    mapping(address => CurrentCommission) public currentCommission;

    /// @notice Store the new commission value for some shops which takes effect after delay time
    mapping(address => SubmitCommission) public submitCommission;

    /// @notice Store the list of addresses of registered shops
    /// @dev Store the list of addresses of registered shops
    EnumerableSetUpgradeable.AddressSet internal _shops;

    /// @notice Initializes management contract and general commission
    /// @dev Initializes management contract and general commission
    /// @param management_ the address of management
    function initialize(address management_) external virtual initializer {
        currentCommission[address(0)] = CurrentCommission(PERCENTAGE_1, true);
        __Managed_init(management_);
        emit SubmitChangeCommission(address(0), PERCENTAGE_1);
    }

    /// @notice Register new shop manually
    /// @dev Register new shop manually by member with permission
    /// @param shop_ the address of new shop
    function registerShop(address shop_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_REGISTER_REMOVE_SHOP)
    {
        require(shop_ != address(0), ERROR_INVALID_ADDRESS);
        _registerShop(shop_);
    }

    /// @notice Remove address of registered shop from shop list
    /// @dev Remove address of registered shop from shop list
    /// @param shop_ the address of registered shop
    function removeShop(address shop_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_REGISTER_REMOVE_SHOP)
    {
        require(_shops.remove(shop_), ERROR_IS_NOT_EXISTS);
        emit RemoveShop(shop_);
    }

    /// @notice Submit proposal about change commission to shop
    /// @dev Zero address is used to store general commission to all shops
    /// @param shop_ the address of shop
    /// @param commission_ the specific commission value
    function submitChangeCommission(address shop_, uint256 commission_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_SET_COMMISION)
    {
        require(commission_ <= MAX_COMMISION, ERROR_MORE_THEN_MAX);
        submitCommission[shop_] = SubmitCommission(commission_, block.timestamp, true);
        emit SubmitChangeCommission(shop_, commission_);
    }

    /// @notice Confirm proposal about change commission to shop
    /// @dev Can be call after method "submitChangeCommission" will be executed
    /// @param shop_ the address of shop
    function confirmChangeCommission(address shop_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_SET_COMMISION)
    {
        require(submitCommission[shop_].isSubmit, ERROR_ACCESS_DENIED);
        SubmitCommission storage shopCommission = submitCommission[shop_];
        require(block.timestamp >= shopCommission.submissionDate + DELAY_TIME, ERROR_DELAY_IS_NOT_OVER);
        delete shopCommission.isSubmit;
        currentCommission[shop_] = CurrentCommission(shopCommission.commission, true);
        emit ConfirmChangeCommission(shop_, shopCommission.commission);
    }

    /// @notice Add or remove shop to/from BlackList (all operations disabled to this shop)
    /// @dev Add or remove shop to/from BlackList (all operations disabled to this shop)
    /// @param shop_ the address of shop
    /// @param isBlackList_ whether add shop to BlackList (true or false)
    function setShopToBlackList(address shop_, bool isBlackList_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_SET_SHOP_ACCESS)
    {
        require(_hasPermission(shop_, SHOPS_MANAGER_BLACK_LIST_PERM) != isBlackList_, ERROR_IS_SET);
        management.setPermission(shop_, SHOPS_MANAGER_BLACK_LIST_PERM, isBlackList_);
        emit SetShopToBlackList(shop_, isBlackList_);
    }

    /// @notice Add or remove shop to/from FreezeList (withdraw funds disabled to this shop)
    /// @dev Add or remove shop to/from FreezeList (withdraw funds disabled to this shop)
    /// @param shop_ the address of shop
    /// @param isFreezeList_ whether add shop to FreezeList (true or false)
    function setShopToFreezeList(address shop_, bool isFreezeList_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_SET_SHOP_ACCESS)
    {
        require(_hasPermission(shop_, SHOPS_MANAGER_FREEZE_LIST_PERM) != isFreezeList_, ERROR_IS_SET);
        management.setPermission(shop_, SHOPS_MANAGER_FREEZE_LIST_PERM, isFreezeList_);
        emit SetShopToFreezeList(shop_, isFreezeList_);
    }

    /// @notice Set automatic or manual register mode
    /// @dev Set register mode(automatic - should register new shop when payment will process for new shop)
    /// @param mode_ is automatic or manual register mode
    function setRegisterMode(RegisterMode mode_)
        external
        virtual
        override
        requirePermission(SHOPS_MANAGER_CAN_REGISTER_REMOVE_SHOP)
    {
        require(registerMode != mode_, ERROR_IS_SET);
        registerMode = mode_;
        emit SetRegisterMode(mode_);
    }

    /// @notice Check whether shop can receive payment which was call from KRUShopsPaymentProccesor
    /// @dev Check whether shop can receive payment which was call from KRUShopsPaymentProccesor
    /// @param shop_ the address of shop
    function checkPaymentShop(address shop_)
        external
        virtual
        override
        canCallOnlyRegisteredContract(CONTRACT_KRU_SHOPS_PAYMENT_PROCCESOR)
    {
        require(shop_ != address(0), ERROR_INVALID_ADDRESS);
        require(!_hasPermission(shop_, SHOPS_MANAGER_BLACK_LIST_PERM), ERROR_ACCESS_DENIED);
        if (!_shops.contains(shop_)) {
            require(registerMode == RegisterMode.Automatic, ERROR_ACCESS_DENIED);
            _registerShop(shop_);
        }
    }

    /// @notice Return commission value for shop (specific commission has higher priority than general)
    /// @dev Return commission value for shop (specific commission has higher priority than general)
    /// @param shop_ the address of shop
    function getCommission(address shop_) external view virtual override returns (uint256) {
        require(_shops.contains(shop_), ERROR_IS_NOT_EXISTS);
        return
            currentCommission[shop_].isValue
                ? currentCommission[shop_].commission
                : currentCommission[address(0)].commission;
    }

    /// @notice Check whether was shop registered
    /// @dev Check whether was shop registered
    /// @param shop_ the address of shop
    function isRegistered(address shop_) external view virtual override returns (bool) {
        return _shops.contains(shop_);
    }

    /// @notice Register new shop manually
    /// @dev Register new shop manually by member with permission
    /// @param shop_ the address of new shop
    function _registerShop(address shop_) internal virtual {
        require(_shops.add(shop_), ERROR_IS_EXISTS);
        management.setPermission(shop_, SHOPS_MANAGER_FREEZE_LIST_PERM, true);
        emit RegisterShop(shop_);
    }
}
