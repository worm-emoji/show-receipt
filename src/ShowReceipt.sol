// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "ERC721A/ERC721A.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/utils/Strings.sol";

contract ShowReceipt is ERC721A, Ownable {
    string public baseURI;
  
    constructor(string memory _baseURI) ERC721A("Show This Receipt At Exit", "RCPT") {
        baseURI = _baseURI;
        _mint(msg.sender, 14);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    // Admin functions
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    // View functions
    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, Strings.toString(tokenID)));
    }
}
