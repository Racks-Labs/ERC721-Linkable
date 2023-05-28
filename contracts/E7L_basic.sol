// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./ERC721Linkable.sol";

contract E7LBasic is ERC721Linkable {
    IERC721 public immutable parentContract;

    constructor(
        string memory _name,
        string memory _symbol,
        IERC721 _parentContract
    ) ERC721Linkable(_name, _symbol) {
        parentContract = _parentContract;
    }

    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }

    function linkToken(
        uint256 tokenId,
        uint256 parentTokenId,
        IERC721
    ) external {
        _linkToken(tokenId, parentTokenId, parentContract);
    }
}
