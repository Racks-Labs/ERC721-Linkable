// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

struct LinkableToken {
    uint256 parentTokenId;
    IERC721 parentContract;
}
