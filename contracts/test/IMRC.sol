//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IMRC is IERC721Enumerable {
    function walletOfOwner(
        address account
    ) external view returns (uint256[] memory);
}
