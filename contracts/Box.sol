// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "./interfaces/IBox.sol";

contract Box is IBox {
    uint256 public boxNumber;
    uint256 public boxPrice;
    address public owner;
    BoxInfo[] internal _boxes;

    constructor(uint256 boxPrice_) {
        boxPrice = boxPrice_;
        owner = msg.sender;
    }

    function store(string memory content_) external payable override {
        if (msg.value < boxPrice) revert NotEnoughtFunds("Should be more than", boxPrice);
        if (msg.sender != owner) revert AccessDenied(msg.sender);
        BoxInfo memory info;
        info.content = content_;
        info.buyer = msg.sender;
        _boxes.push(info);
        boxNumber++;
        emit StoreBox(msg.sender, info);
    }

    function getBoxInfo(uint256 index_) external view returns (BoxInfo memory) {
        return _boxes[index_];
    }
}
