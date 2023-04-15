// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./ERC721LinkableUpgradeable.sol";

contract E7LUpgradeableBasic is ERC721LinkableUpgradeable {
    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }
}
