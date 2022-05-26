// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/draft-EIP712Upgradeable.sol";
import "../interfaces/IManagement.sol";
import "./Constants.sol";

/// @title ManagementUpgradeable
/// @author Applicature
/// @notice This contract allows set permission or permissions for sender,
/// set owner of the pool, set kyc whitelist, register contract etc
/// @dev This contract allows set permission or permissions for sender,
/// set owner of the pool, set kyc whitelist, register contract etc
contract ManagementUpgradeable is IManagement, EIP712Upgradeable, OwnableUpgradeable {
    /// @notice Gets the registered contract by key
    /// @dev Gets the registered contract by key
    /// @return Returns the registered contract by key
    mapping(uint256 => address payable) public override contractRegistry;

    /// @notice Value true or false for all sender's permissions
    /// @dev Value true or false for all sender's permissions
    mapping(address => mapping(uint256 => bool)) internal _permissions;

    /// @notice Contain which rights a certain address can give to other addresses
    /// @dev Contain which rights a certain address can give to other addresses
    mapping(address => mapping(uint256 => bool)) internal _limitSetPermissions;

    /// @notice Initializes name of the signing domain and current version
    /// @dev Initializes name of the signing domain and current version
    function initialize() external virtual initializer {
        __Ownable_init();
        __EIP712_init("ManagementUpgradeable", "v1");
    }

    /// @notice Sets the kyc whitelist
    /// @dev Sets the kyc whitelist
    /// @param addresses_ the addresses that need to whitelist
    /// @param value_ the true or false for kyc whitelist
    function setKycWhitelists(address[] calldata addresses_, bool value_) external virtual override {
        require(_permissions[_msgSender()][MANAGEMENT_CAN_SET_KYC_WHITELISTED], ERROR_ACCESS_DENIED);
        for (uint256 i = 0; i < addresses_.length; i++) {
            _permissions[addresses_[i]][MANAGEMENT_WHITELISTED_KYC] = value_;
        }
        emit UsersPermissionsSet(addresses_, MANAGEMENT_WHITELISTED_KYC, value_);
    }

    /// @notice Sets the limit grant access to gran permissions
    /// @dev  Sets the limit grant access to gran permissions
    /// @param address_ the address of sender
    /// @param permission_ the permission which address_ can grant
    /// @param value_ true or false for address_ permission
    function setLimitSetPermission(
        address address_,
        uint256 permission_,
        bool value_
    ) external virtual override onlyOwner {
        _limitSetPermissions[address_][permission_] = value_;
        emit LimitSetPermission(address_, permission_, value_);
    }

    /// @notice Sets the permission for sender
    /// @dev  Sets the permission for sender by owner or address with limit set permissions
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @param value_ true or false for sender's permission
    function setPermission(
        address address_,
        uint256 permission_,
        bool value_
    ) external virtual override {
        require(owner() == _msgSender() || _limitSetPermissions[_msgSender()][permission_], ERROR_ACCESS_DENIED);
        _permissions[address_][permission_] = value_;
        emit PermissionSet(address_, permission_, value_);
    }

    /// @notice Sets the permissions for sender
    /// @dev Sets the permissions for sender by owner
    /// @param address_ the address of sender
    /// @param permissions_ the permissions for sender
    /// @param value_ true or false for sender's permissions
    function setPermissions(
        address address_,
        uint256[] calldata permissions_,
        bool value_
    ) external virtual override onlyOwner {
        for (uint256 i = 0; i < permissions_.length; i++) {
            _permissions[address_][permissions_[i]] = value_;
        }
        emit PermissionsSet(address_, permissions_, value_);
    }

    /// @notice Registrates contract
    /// @dev Registrates contract by owner
    /// @param key_ the number that corresponds to the registered address
    /// @param target_ the address that must to be registered
    function registerContract(uint256 key_, address payable target_) external virtual override onlyOwner {
        require(target_ != address(0), ERROR_INVALID_ADDRESS);
        contractRegistry[key_] = target_;
        emit ContractRegistered(key_, target_);
    }

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
    ) external view virtual override returns (bool) {
        if (_permissions[address_][MANAGEMENT_WHITELISTED_KYC]) {
            return true;
        } else {
            require(deadline_ > block.timestamp, ERROR_TIME_OUT);
            bytes32 structHash = keccak256(abi.encode(KYC_CONTAINER_TYPEHASE, address_, deadline_));
            bytes32 hash = _hashTypedDataV4(structHash);
            address messageSigner = ECDSAUpgradeable.recover(hash, v_, r_, s_);
            return _permissions[messageSigner][MANAGEMENT_KYC_SIGNER];
        }
    }

    /// @notice Gets whether the sender has permission
    /// @dev Gets whether the sender has permission
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @return Returns whether the sender has permission
    function permissions(address address_, uint256 permission_) external view virtual override returns (bool) {
        return _permissions[address_][permission_];
    }

    /// @notice Returns whether the user can grant right to someone
    /// @dev Returns whether the user can grant right to someone
    /// @param address_ the address of sender
    /// @param permission_ the permission for sender
    /// @return Returns whether the user can grant right to someone
    function limitSetPermissions(address address_, uint256 permission_) external view virtual override returns (bool) {
        return _limitSetPermissions[address_][permission_];
    }
}
