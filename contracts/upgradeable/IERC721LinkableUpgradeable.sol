// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "../Linkable.sol";

interface IERC721LinkableUpgradeable is IERC721Upgradeable {
    event Link(uint256 tokenId, uint256 parentTokenId, IERC721 parentContract);
    event Unlink(uint256 tokenId);

    function tokenInfo(
        uint256 tokenId
    ) external view returns (LinkableToken memory);

    function linkToken(
        uint256 tokenId,
        uint256 parentTokenId,
        IERC721 parentContract
    ) external;

    function syncToken(uint256 tokenId) external;
}
