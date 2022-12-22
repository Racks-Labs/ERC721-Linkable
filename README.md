# About ERC 721-Linkable

The goal of ERC 721L is to allow nfts to be linked in a relationship where there is a main NFT lets call it NFT A, and there is n number of ERC721L contracts linked to it, once nft A is transfered the new owner can claim the rest of the nfts linked to the main token.

It creates a bunch of new oportunities to bring value to you holders and create new online experiences. Let's see 2 possible use cases below.

ERC721L allows you to create experiences where people can earn a erc721l and link it to their favourite nft of your project increasing the percieved value of it and giving a onchain reputation linked to that token.

It can also be used to create a multi nft drop, for example a phisically backed hoodie that has a linked pfp, a decentraland version of that hoodie and a nft 3d render to show on oncyber. The ownership of all theese nfts will be of the current owner of the hoodie pbt token automatically, and if that token is transfered all theese complementary nft can be claim by the new owner.

## Technical specs

ERC721-Linkable is an extension of the ERC721, the main technical add-ons are the variable parentContract, the struct LinkableToken, and te linkToken and syncToken functions.

the function linktoken initialices a minted token id linking it to a tokenId of the parent contract. If a token is not initialiced it can not be transfered, once it is initialicec it can only bre transfered using the syncToken function that will transfer the nft to the owner of the parent tokenId

## Usage

```solidity
pragma solidity ^0.8.7;

import "./ERC721Linkable.sol";

contract E7L is ERC721Linkable {
	constructor(
        string memory _name,
        string memory _symbol,
        address _parentContract
    ) ERC721Linkable(_name, _symbol, _parentContract) {}

	function mint(uint256 tokenId) public {
		_safeMint(msg.sender, tokenId);
	}
}
```

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
