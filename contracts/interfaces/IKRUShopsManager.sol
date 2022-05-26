// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/// @title IKRUShopsManager
/// @author Applicature
/// @notice There is an interface to KRUShopsManager contract that is used to register the shops etc
/// @dev  There is an interface to KRUShopsManager contract that is used to register the shops etc
interface IKRUShopsManager {
    /// @notice Enumeration of register modes
    /// @dev Enumeration of register modes
    enum RegisterMode {
        Manual,
        Automatic
    }

    /// @notice Structured data type that store information about commission which takes effect after delay time
    /// @dev Structured data type that store information about commission which takes effect after delay time
    /// @param commission the commission value for shop
    /// @param submissionDate the date of proposal has been submitted
    /// @param isSubmit whether proposal has been submitted
    struct SubmitCommission {
        uint256 commission;
        uint256 submissionDate;
        bool isSubmit;
    }

    /// @notice Structured data type for variables that store information about current commission
    /// @dev Structured data type for variables that store information about current commission
    /// @param commission the commission value for shop
    /// @param isValue whether commission is active
    struct CurrentCommission {
        uint256 commission;
        bool isValue;
    }

    /// @notice Generated when admin add or remove shop to/from blacklist
    /// @dev Generated when admin add or remove shop to/from blacklist
    /// @param shop the address of shop
    /// @param isBlackList whether add shop to blacklist (true or false)
    event SetShopToBlackList(address shop, bool isBlackList);

    /// @notice Generated when admin add or remove shop to/from freezelist
    /// @dev Generated when admin add or remove shop to/from freezelist
    /// @param shop the address of shop
    /// @param isFreezeList whether add shop to freezelist (true or false)
    event SetShopToFreezeList(address shop, bool isFreezeList);

    /// @notice Generated when register new shop with manual or auto mode
    /// @dev Generated when register new shop with manual or auto mode
    /// @param shop the address of new shop
    event RegisterShop(address shop);

    /// @notice Generated when admin remove registered shop
    /// @dev Generated when admin remove registered shop
    /// @param shop the address of registered shop
    event RemoveShop(address shop);

    /// @notice Generated when admin set automatic or manual register mode
    /// @dev Generated when admin set automatic or manual register mode
    /// @param mode is automatic or manual register mode
    event SetRegisterMode(RegisterMode mode);

    /// @notice Generated when admin submit proposal about change commission to shop
    /// @dev Generated when admin submit proposal about change commission to shop
    /// @param shop the address of shop
    /// @param commission the specific commission value
    event SubmitChangeCommission(address shop, uint256 commission);

    /// @notice Generated when admin confirm proposal about change commission to shop
    /// @dev Generated when admin confirm proposal about change commission to shop
    /// @param shop the address of shop
    /// @param commission the specific commission value
    event ConfirmChangeCommission(address shop, uint256 commission);

    /// @notice Register new shop manually
    /// @dev Register new shop manually by member with permission
    /// @param shop_ the address of new shop
    function registerShop(address shop_) external;

    /// @notice Remove address of registered shop from shop list
    /// @dev Remove address of registered shop from shop list
    /// @param shop_ the address of registered shop
    function removeShop(address shop_) external;

    /// @notice Add or remove shop to/from BlackList (all operations disabled to this shop)
    /// @dev Add or remove shop to/from BlackList (all operations disabled to this shop)
    /// @param shop_ the address of shop
    /// @param isBlackList_ whether add shop to BlackList (true or false)
    function setShopToBlackList(address shop_, bool isBlackList_) external;

    /// @notice Add or remove shop to/from FreezeList (withdraw funds disabled to this shop)
    /// @dev Add or remove shop to/from FreezeList (withdraw funds disabled to this shop)
    /// @param shop_ the address of shop
    /// @param isFreezeList_ whether add shop to FreezeList (true or false)
    function setShopToFreezeList(address shop_, bool isFreezeList_) external;

    /// @notice Set automatic or manual register mode
    /// @dev Set register mode(automatic - should register new shop when payment will process for new shop)
    /// @param mode_ is automatic or manual register mode
    function setRegisterMode(RegisterMode mode_) external;

    /// @notice Submit proposal about change commission to shop
    /// @dev Zero address is used to store general commission to all shops
    /// @param shop_ the address of shop
    /// @param commission_ the specific commission value
    function submitChangeCommission(address shop_, uint256 commission_) external;

    /// @notice Confirm proposal about change commission to shop
    /// @dev Can be call after method "submitChangeCommission" will be executed
    /// @param shop_ the address of shop
    function confirmChangeCommission(address shop_) external;

    /// @notice Check whether shop can receive payment which was call from KRUShopsPaymentProccesor
    /// @dev Check whether shop can receive payment which was call from KRUShopsPaymentProccesor
    /// @param shop_ the address of shop
    function checkPaymentShop(address shop_) external;

    /// @notice Return commission value for shop (specific commission has higher priority than general)
    /// @dev Return commission value for shop (specific commission has higher priority than general)
    /// @param shop_ the address of shop
    function getCommission(address shop_) external view returns (uint256);

    /// @notice Return actual register mode
    /// @dev Return actual register mode
    function registerMode() external view returns (RegisterMode);

    /// @notice Check whether was shop registered
    /// @dev Check whether was shop registered
    /// @param shop_ the address of shop
    function isRegistered(address shop_) external view returns (bool);
}
