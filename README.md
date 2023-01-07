[![NPM](https://img.shields.io/npm/v/erc721l?color=%23cc3534&style=for-the-badge&logo=npm&logoColor=white)](https://www.npmjs.com/package/erc721l)



# About ERC 721-Linkable

The goal of ERC-721Linkable is to allow nfts to be linked. The nfts that implements this standar is non transferable until it is linked to a nft of other smart contract (parent token), once the E7L is linked it can only be transfered to the current owner of the parent token.

It creates a bunch of new oportunities to bring value to you holders and create new online experiences. Let's see 2 possible use cases below.

ERC721L allows you to create experiences where people can earn a erc721l and link it to their favourite nft of your project increasing the percieved value of it and allowing an NFT to have on chain reputation, kind of a POAP but for tokens.

It can also be used to create a multi nft drop, for example a phisically backed hoodie that has a linked pfp, a decentraland version of that hoodie and a nft 3d render to show on oncyber. The ownership of all theese nfts will be of the current owner of the hoodie pbt token automatically, and if that token is transfered all theese complementary nft can be claim by the new owner.

## Technical specs

ERC721-Linkable is an extension of the ERC721, the main technical add-ons are the variable parentContract, the struct LinkableToken, and te linkToken and syncToken functions.

The function linktoken initialize a minted token id linking it to a tokenId of the parent contract. If a token is not initialized it can not be transfered, once it is initialiced it can only be transfered using the syncToken function that will transfer the nft to the current owner of the parent token ID.

## Usage

In order to use ERC721L you just need to install the following npm package.

```shell
npm i erc721l
```

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

During the development process of the standard we have realiced that the ui and ux is really important in a project that implements this standar. So we are working on a sub graph base repo to help with that.

Also we have noticed that could be great to not only have 1 parent smart contract and allow a single e7l contract to have n number of parent contracts checking if when a token is linked the parent implements the ERC721 interface, so we are working in adding the ERC721ultilinkable contract.
