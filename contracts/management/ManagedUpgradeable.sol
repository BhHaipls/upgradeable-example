// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interfaces/IManagement.sol";
import "./Constants.sol";

/// @title Managed
/// @author Applicature
/// @notice This contract allows initialize the address of management, set permission for sender etc
/// @dev This contract allows initialize the address of management, set permission for sender etc
abstract contract ManagedUpgradeable is OwnableUpgradeable {
    /// @notice The state variable of IManagement interface
    /// @dev The state variable of IManagement interface
    IManagement public management;

    /// @notice Checks whether the sender has permission prior to executing the function
    /// @dev Checks whether the sender has permission prior to executing the function
    /// @param permission_ the permission for sender
    modifier requirePermission(uint256 permission_) {
        require(_hasPermission(_msgSender(), permission_), ERROR_ACCESS_DENIED);
        _;
    }

    /// @notice Checks whether the sender is a registered contract
    /// @dev Checks whether the sender is a registered contract
    /// @param key_ the number that corresponds to the registered address
    modifier canCallOnlyRegisteredContract(uint256 key_) {
        require(_msgSender() == management.contractRegistry(key_), ERROR_ACCESS_DENIED);
        _;
    }

    /// @notice Initializes the address of management after deployment
    /// @dev Initializes the address of management after deployment by owner of smart contract
    /// @param managementAddress_ the address of management
    function setManagementContract(address managementAddress_) external virtual onlyOwner {
        require(address(0) != managementAddress_, ERROR_NO_CONTRACT);
        management = IManagement(managementAddress_);
    }

    /// @notice Initializes the address of management and initial owner
    /// @dev Initializes the address of management, initial owner and protect from being invoked twice
    /// @param managementAddress_ the address of management
    /* solhint-disable */
    function __Managed_init(address managementAddress_) internal virtual onlyInitializing {
        require(address(0) != managementAddress_, ERROR_NO_CONTRACT);
        management = IManagement(managementAddress_);
        __Ownable_init();
    }

    /// @notice Checks whether the sender has permission
    /// @dev Checks whether the sender has permission
    /// @param subject_ the address of sender
    /// @param permission_ the permission for sender
    /// @return Returns whether the sender has permission
    function _hasPermission(address subject_, uint256 permission_) internal view virtual returns (bool) {
        return management.permissions(subject_, permission_);
    }
}
