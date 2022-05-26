// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IBoxV2 {
    struct BoxInfo {
        address buyer;
        string content;
        uint256 number;
    }

    function store(string memory content_) external payable;

    function initialize(uint256 boxPrice_) external;

    function withdrawEthers() external;
    
    /// @notice Returns info about box
    /// @dev Returns info about box
    /// @param index_ index of box
    /// @return BoxInfo structure
    function getBoxInfo(uint256 index_) external view returns (BoxInfo memory);

    error AccessDenied(address caller);

    error NotEnoughtFunds(string message, uint256 minPrice);

    event StoreBox(address caller, BoxInfo info);
}
