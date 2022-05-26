// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/// @title ManagementUpgradeable
/// @author Applicature
/// @notice This contract allows set permission or permissions for sender,
/// set owner of the pool, set kyc whitelist, register contract etc
/// @dev This contract allows set permission or permissions for sender,
/// set owner of the pool, set kyc whitelist, register contract etc
interface IManagement {
    /// @notice Generated when admin set limit set permissions for user
    /// @dev Generated when admin set limit set permissions for user
    /// @param subject address which recive limit set permissions
    /// @param permissions id of permissions which was limit set permissions
    /// @param value Bool state of permission (true - enable, false - disable for subject)
    event LimitSetPermission(address indexed subject, uint256 indexed permissions, bool value);

    /// @notice Generated when admin set new permissions for user
    /// @dev Generated when admin/or user with limit set permissions set new permissions for user
    /// @param subject address which recive permissions
    /// @param permissions id's of permissions which was set
    /// @param value Bool state of permission (true - enable, false - disable for subject)
    event PermissionsSet(address indexed subject, uint256[] indexed permissions, bool value);

    /// @notice Generated when admin set new permissions for user
    /// @dev Generated when admin/or user with limit set permissions set new permissions for user
    /// @param subject array with addresses which permissions was update
    /// @param permissions id of permission which was set
    /// @param value Bool state of permission (true - enable, false - disable for subject)
    event UsersPermissionsSet(address[] indexed subject, uint256 indexed permissions, bool value);

    /// @notice Generated when admin set new permissions for user
    /// @dev Generated when admin/or user with limit set permissions set new permissions for user
    /// @param subject address which recive permissions
    /// @param permission id of permission which was set
    /// @param value Bool state of permission (true - enable, false - disable for subject)
    event PermissionSet(address indexed subject, uint256 indexed permission, bool value);

    /// @notice Generated when admin register new contract
    /// @dev Generated when admin register new contract by key
    /// @param key id on which the contract is registered
    /// @param target address contract which was registered
    event ContractRegistered(uint256 indexed key, address target);

    /// @notice Sets the permission for sender
    /// @dev  Sets the permission for sender by owner or address with limit set permissions
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @param value_ true or false for sender's permission
    function setPermission(
        address address_,
        uint256 permission_,
        bool value_
    ) external;

    /// @notice Sets the permissions for sender
    /// @dev Sets the permissions for sender by owner
    /// @param address_ the address of sender
    /// @param permissions_ the permissions for sender
    /// @param value_ true or false for sender's permissions
    function setPermissions(
        address address_,
        uint256[] calldata permissions_,
        bool value_
    ) external;

    /// @notice Sets the limit grant access to gran permissions
    /// @dev  Sets the limit grant access to gran permissions
    /// @param address_ the address of sender
    /// @param permission_ the permission which address_ can grant
    /// @param value_ true or false for address_ permission
    function setLimitSetPermission(
        address address_,
        uint256 permission_,
        bool value_
    ) external;

    /// @notice Registrates contract
    /// @dev Registrates contract by owner
    /// @param key_ the number that corresponds to the registered address
    /// @param target_ the address that must to be registered
    function registerContract(uint256 key_, address payable target_) external;

    /// @notice Sets the kyc whitelist
    /// @dev Sets the kyc whitelist
    /// @param addresses_ the addresses that need to whitelist
    /// @param value_ the true or false for kyc whitelist
    function setKycWhitelists(address[] calldata addresses_, bool value_) external;

    /// @notice Checks whether the sender has passed kyc
    /// @dev Checks whether the sender has passed kyc
    /// @param address_ the address of sender
    /// @param deadline_ deadline in Unix timestamp
    /// @param v_ one of the signature parameters
    /// @param r_ one of the signature parameters
    /// @param s_ one of the signature parameters
    /// @return Returns whether the sender has passed kyc
    function isKYCPassed(
        address address_,
        uint256 deadline_,
        uint8 v_,
        bytes32 r_,
        bytes32 s_
    ) external view returns (bool);

    /// @notice Gets the registered contract by key
    /// @dev Gets the registered contract by key
    /// @param key_ the number that corresponds to the registered address
    /// @return Returns the registered contract by key
    function contractRegistry(uint256 key_) external view returns (address payable);

    /// @notice Gets whether the sender has permission
    /// @dev Gets whether the sender has permission
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @return Returns whether the sender has permission
    function permissions(address address_, uint256 permission_) external view returns (bool);

    /// @notice Returns whether the user can grant right to someone
    /// @dev Returns whether the user can grant right to someone
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @return Returns whether the user can grant right to someone
    function limitSetPermissions(address address_, uint256 permission_) external view returns (bool);
}
