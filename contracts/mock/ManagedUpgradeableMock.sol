// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "../management/ManagedUpgradeable.sol";

contract ManagedUpgradeableMock is ManagedUpgradeable {
    function initialize(address management_) external initializer {
        __Managed_init(management_);
    }

    function hasPermission(address _subject, uint256 _permission) external view requirePermission(1) returns (bool) {
        return _hasPermission(_subject, _permission);
    }

    function canCallOnly() external view canCallOnlyRegisteredContract(1) returns (bool) {
        return true;
    }
}
