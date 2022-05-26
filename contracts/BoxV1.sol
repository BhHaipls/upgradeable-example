// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
import "./interfaces/IBoxV1.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract BoxV1 is IBoxV1, ContextUpgradeable {
    uint256 public boxPrice;
    uint256 public boxNumber;
    address public manager;

    BoxInfo[] internal _boxes;

    function initialize(uint256 boxPrice_) external virtual override initializer {
        __Context_init();
        boxPrice = boxPrice_;
        manager = _msgSender();
    }

    function store(string memory content_) external payable virtual override {
        if (msg.value < boxPrice) revert NotEnoughtFunds("Should be more than", boxPrice);
        if (_msgSender() != manager) revert AccessDenied(_msgSender());
        BoxInfo memory info;
        info.content = content_;
        info.buyer = _msgSender();
        _boxes.push(info);
        boxNumber++;
        emit StoreBox(_msgSender(), info);
    }

    function getBoxInfo(uint256 index_) external view virtual override returns (BoxInfo memory) {
        return _boxes[index_];
    }
}
