// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "./ERC721LinkableUpgradeable.sol";

contract E7LUpgradeableBasic is ERC721LinkableUpgradeable {
    IERC721 public parentContract;

    function initialize(
        string memory name_,
        string memory symbol_,
        IERC721 parentContract_
    ) public initializer {
        __ERC721_init(name_, symbol_);
        __ERC721Linkable_init();
        parentContract = parentContract_;
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

    function unlinkToken(uint256 tokenId) external {
        _unlinkToken(tokenId);
    }
}
