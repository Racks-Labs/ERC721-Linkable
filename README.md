<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a name="readme-top"></a>

[![NPM](https://img.shields.io/npm/v/erc721l?color=%23cc3534&style=for-the-badge&logo=npm&logoColor=white)](https://www.npmjs.com/package/erc721l)
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/Racks-Labs/ERC721-Linkable">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="README/E7L-Black.svg">
      <source media="(prefers-color-scheme: dark)" srcset="README/E7L-White.svg">
      <img src="README/E7L-Black.svg" alt="E7L logo" width="500">
    </picture>
  </a>
<h3 align="center">E7L Standard</h3>
  <p align="center">
    <b>A new way of linking 🔗</b>
    <br />
    <a href="https://e7l.rackslabs.com"><strong>Explore the website »</strong></a>
    <br />
    <br />
    <a href="https://github.com/Racks-Labs/ERC721-Linkable/issues">Report Bug</a>
    ·
    <a href="https://github.com/Racks-Labs/ERC721-Linkable/issues">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-erc-721-linkable">About ERC 721-Linkable</a>
    </li>
    <li><a href="#technical-specs">Technical specs</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#future-improvements">Future improvements</a></li>
  </ol>
</details>

## About ERC 721 Linkable

[![E7L teaser][e7l-teaser]](https://e7l.rackslabs.com)

The goal of ERC-721Linkable(E7L) is to allow nfts to be linked. The nfts that implements this standard is non-transferable until it is linked to a nft of other smart contract (parent token), once the E7L is linked it can only be transferred to the current owner of the parent token.

It creates a bunch of new opportunities to bring value to you holders and create new online experiences. Let's see 2 possible use cases below.

E7L allows you to create experiences where people can earn an E7L and link it to their favourite nft of your project increasing the perceived value of it and allowing an NFT to have on chain reputation, kind of POAP but for tokens.

It can also be used to create a multi nft drop, for example a physically backed hoodie that has a linked pfp, a decentralized version of that hoodie and a nft 3d render to show on oncyber. The ownership of all these nfts will be of the current owner of the hoodie pbt token automatically, and if that token is transferred all these complementary nft can be claim by the new owner.

## Technical specs

ERC-721Linkable is an extension of the ERC-721, the main technical add-ons are the variable parentContract, the struct LinkableToken, and the `_linkToken` `_unlinkToken` and `syncToken` functions.

The function `_linkToken` initialize a minted token id linking it to a tokenId of the parent contract. If a token is not initialized it can not be transferred, once it is initialized it can only be transferred using the `syncToken` function that will transfer the nft to the current owner of the parent token ID. The function `_unlinkToken` reverts that token to the initial state. This last function is intended to be used only with an access control management.

## Getting started

In order to use E7L you just need to install the following npm package.

```shell
npm i erc721l
```

or

```shell
yarn add erc721l
```

<br/>

Once you have all the contracts you just need to create a new solidity file, import the ERC721Linkable contract and make your contract.

```solidity
pragma solidity ^0.8.7;

import "erc721l/contracts/ERC721Linkable.sol";

contract E7L is ERC721Linkable {
  constructor(
    string memory _name,
    string memory _symbol,
    address _parentContract
  ) ERC721Linkable(_name, _symbol, _parentContract) {}

  function mint(uint256 tokenId) public {
    _safeMint(msg.sender, tokenId);
  }

  // CUSTOM CODE GOES HERE
}
```

## Future improvements

During the development process of the standard we have realized that the ui and ux is really important in a project that implements this standard. So we are working on a sub graph base repo to help with that.

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/Racks-Labs/ERC721-Linkable.svg?style=for-the-badge
[contributors-url]: https://github.com/Racks-Labs/ERC721-Linkable/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Racks-Labs/ERC721-Linkable.svg?style=for-the-badge
[forks-url]: https://github.com/Racks-Labs/ERC721-Linkable/network/members
[stars-shield]: https://img.shields.io/github/stars/Racks-Labs/ERC721-Linkable.svg?style=for-the-badge
[stars-url]: https://github.com/Racks-Labs/ERC721-Linkable/stargazers
[issues-shield]: https://img.shields.io/github/issues/Racks-Labs/ERC721-Linkable.svg?style=for-the-badge
[issues-url]: https://github.com/Racks-Labs/ERC721-Linkable/issues
[e7l-teaser]: README/Teaser.gif
