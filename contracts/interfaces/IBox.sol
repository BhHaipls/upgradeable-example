// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IBox {
    struct BoxInfo {
        address buyer;
        string content;
    }

    function store(string memory content_) external payable;
    
    /// @notice Returns info about box
    /// @dev Returns info about box
    /// @param index_ index of box
    /// @return BoxInfo structure
    function getBoxInfo(uint256 index_) external view returns (BoxInfo memory);

    error AccessDenied(address caller);

    error NotEnoughtFunds(string message, uint256 minPrice);

    event StoreBox(address caller, BoxInfo info);
}
