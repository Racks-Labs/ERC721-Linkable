// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../Linkable.sol";

interface IERC721LinkableUpgradeable is IERC721 {

    event Link(uint256 tokenId, uint256 parentTokenId);

    function initialize(string memory name_, string memory symbol_, address parentContract_) external;

    function tokenInfo(uint256 tokenId) external view returns (LinkableToken memory);

    function linkToken(uint256 tokenId, uint256 parentTokenId) external;

    function syncToken(uint256 token) external;
}
