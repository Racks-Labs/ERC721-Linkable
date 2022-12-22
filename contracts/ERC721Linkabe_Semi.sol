// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./ERC721Linkable.sol";

abstract contract ERC721Linkable_Semi is ERC721Linkable {

    constructor(
        string memory _name,
        string memory _symbol,
        address _parentContract
    ) ERC721Linkable(_name, _symbol, _parentContract) {}

    function ownerOf(uint256 tokenId) public view virtual override(ERC721, IERC721) returns (address) {
        if (tokenInfo(tokenId).linked == true)
            return parentContract.ownerOf(tokenInfo(tokenId).parentTokenId);

        return super.ownerOf(tokenId);
    }
}
