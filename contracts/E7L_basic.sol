// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./ERC721Linkable.sol";

contract E7LBasic is ERC721Linkable {
    constructor(
        string memory _name,
        string memory _symbol,
        address _parentContract
    ) ERC721Linkable(_name, _symbol, _parentContract) {}

    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }
}
