// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./Linkable.sol";

interface IERC721Linkable is IERC721 {
    event Link(uint256 tokenId, uint256 indexed parentTokenId);

    function tokenInfo(
        uint256 tokenId
    ) external view returns (LinkableToken memory);

    function linkToken(uint256 tokenId, uint256 parentTokenId) external;

    function syncToken(uint256 token) external;
}
