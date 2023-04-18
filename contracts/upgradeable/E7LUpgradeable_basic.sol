// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./ERC721LinkableUpgradeable.sol";

contract E7LUpgradeableBasic is ERC721LinkableUpgradeable {
    function initialize(
        string memory name_,
        string memory symbol_,
        address parentContract_
    ) public initializer {
        __ERC721_init(name_, symbol_);
        __ERC721Linkable_init(parentContract_);
    }

    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }
}
