// SPDX-License-Identifier: MIT

/*
																									   .         .
8 888888888o.            .8.           ,o888888o.    8 8888     ,88'   d888888o.                      ,8.       ,8.                   .8.          8 8888888888    8 8888          .8.
8 8888    `88.          .888.         8888     `88.  8 8888    ,88'  .`8888:' `88.                   ,888.     ,888.                 .888.         8 8888          8 8888         .888.
8 8888     `88         :88888.     ,8 8888       `8. 8 8888   ,88'   8.`8888.   Y8                  .`8888.   .`8888.               :88888.        8 8888          8 8888        :88888.
8 8888     ,88        . `88888.    88 8888           8 8888  ,88'    `8.`8888.                     ,8.`8888. ,8.`8888.             . `88888.       8 8888          8 8888       . `88888.
8 8888.   ,88'       .8. `88888.   88 8888           8 8888 ,88'      `8.`8888.                   ,8'8.`8888,8^8.`8888.           .8. `88888.      8 888888888888  8 8888      .8. `88888.
8 888888888P'       .8`8. `88888.  88 8888           8 8888 88'        `8.`8888.                 ,8' `8.`8888' `8.`8888.         .8`8. `88888.     8 8888          8 8888     .8`8. `88888.
8 8888`8b          .8' `8. `88888. 88 8888           8 888888<          `8.`8888.               ,8'   `8.`88'   `8.`8888.       .8' `8. `88888.    8 8888          8 8888    .8' `8. `88888.
8 8888 `8b.       .8'   `8. `88888.`8 8888       .8' 8 8888 `Y8.    8b   `8.`8888.             ,8'     `8.`'     `8.`8888.     .8'   `8. `88888.   8 8888          8 8888   .8'   `8. `88888.
8 8888   `8b.    .888888888. `88888.  8888     ,88'  8 8888   `Y8.  `8b.  ;8.`8888            ,8'       `8        `8.`8888.   .888888888. `88888.  8 8888          8 8888  .888888888. `88888.
8 8888     `88. .8'       `8. `88888.  `8888888P'    8 8888     `Y8. `Y8888P ,88P'           ,8'         `         `8.`8888. .8'       `8. `88888. 8 8888          8 8888 .8'       `8. `88888.
*/

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IMRC.sol";

contract MRCRYPTO is ERC721Enumerable, Ownable, IMRC {
    using Strings for uint256;

    string baseURI;
    string public baseExtension = ".json";
    string public notRevealedUri;
    uint256[3] public cost = [18.5 ether, 26 ether, 37 ether];
    uint256 public totalMaxSupply = 10000;

    uint256 public previousMaxSupply = 0;
    uint256 public maxMintAmount = 20;
    bool public paused = true;
    bool public revealed = false;
    bool public whitelistOn = false;
    bool public lockURI = false;
    bool public lockExt = false;

    address liquidity = 0x9931F0108A281A0a4B78613156a039e6aEFc59e4;
    mapping(address => bool) public isWhitelisted;
    mapping(uint256 => bool) public reservedMints;
    mapping(address => bool) public isAdmin;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);

        /* giveAway(1, 0x844435cD4f8Efab891a7e10a1A03e6ee8C47A366); //RACKS
		giveAway(1, 0x8407A400dAdFd053199b1e67Fe75ba1e9d76D3A1); //DEV1
		giveAway(1, 0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5); //DEV2
		giveAway(1, 0xbCbb32C0caC8833061D6281e934B20bb93004255); //DEV3
		giveAway(1, 0xa3B17117F104e5965e98F07fe007784F6e3F3A2D); //PRESENT
		giveAway(1, 0x4aBb876da9c5A48D64753Cd077B3f5b870856ed8); //RACKS2
		giveAway(1, 0xC608d2dD5AFA199a0c0E487Fdd669c1AD7459bE4); //DEV4

		giveAway(3, 0x844435cD4f8Efab891a7e10a1A03e6ee8C47A366); //RACKS
		giveAway(3, 0x8407A400dAdFd053199b1e67Fe75ba1e9d76D3A1); //YONA
		giveAway(3, 0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5); //DEV2
		giveAway(3, 0xbCbb32C0caC8833061D6281e934B20bb93004255); //DEV3
		giveAway(3, 0x4aBb876da9c5A48D64753Cd077B3f5b870856ed8); //RACKS2
		giveAway(3, 0xC608d2dD5AFA199a0c0E487Fdd669c1AD7459bE4); //DEV4 */
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] || msg.sender == owner());
        _;
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();

        /* require(!paused, "Paused");
		if (whitelistOn == true) require(isWhitelisted[msg.sender] || msg.sender == owner(), "Not whitelisted");
		require(_mintAmount <= maxMintAmount, "Mint amount");
		require(supply + _mintAmount <= totalMaxSupply, "Max supply"); */

        //if (msg.sender != owner())
        //require(msg.value >= cost[phase] * _mintAmount, "Not enough value");

        for (uint256 i = 1; i <= _mintAmount; ++i) {
            _safeMint(msg.sender, supply + i);
        }
    }

    function reservedMint(uint256 _tokenId) public payable {
        //para canjear tokens antiguos por nuevos a precio reducido
        uint256 supply = totalSupply();

        require(!paused);
        require(
            ownerOf(_tokenId) == msg.sender,
            "you are not the owner of that NFT"
        );
        require(supply + 1 <= totalMaxSupply);
        require(
            reservedMints[_tokenId] == false,
            "Token alredy used to mint at reserved price"
        );

        if (_tokenId <= 1000) {
            //require(msg.value >= cost[0]);
            require(supply > 999 && supply <= 3999, "Supply is less than 1000");

            _safeMint(msg.sender, supply + 1);
            reservedMints[_tokenId] = true;
        } else if (_tokenId <= 4000) {
            //require(msg.value >= cost[1]);
            require(supply > 3999);

            _safeMint(msg.sender, supply + 1);
            reservedMints[_tokenId] = true;
        }
    }

    function giveAway(
        uint256 _mintAmount,
        address _to
    ) public payable onlyOwner {
        uint256 supply = totalSupply();

        require(_mintAmount > 0);
        require(supply + _mintAmount <= totalMaxSupply);

        for (uint256 i = 1; i <= _mintAmount; ++i) {
            _safeMint(_to, supply + i);
        }
    }

    function checkPhase(uint256 _supply) internal pure returns (uint256) {
        if (_supply <= 1000) return 0;
        if (_supply <= 4000) return 1;
        return 2;
    }

    function walletOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; ++i) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenUsed(uint256 _tokenId) public view returns (bool) {
        return reservedMints[_tokenId];
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false && tokenId > previousMaxSupply)
            return notRevealedUri;

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
                )
                : "";
    }

    //only owner
    function reveal() public onlyAdmin {
        revealed = true;
        previousMaxSupply = totalSupply();
    }

    function revealAlreadyMinted() public onlyAdmin {
        previousMaxSupply = totalSupply();
    }

    function setCost(uint256 _newCost, uint256 index) public onlyOwner {
        cost[index] = _newCost;
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyAdmin {
        maxMintAmount = _newmaxMintAmount;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyAdmin {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function playPause() public onlyAdmin {
        revealed = false;
        paused = !paused;
    }

    function withdraw() public payable onlyAdmin {
        /* uint256 each = (address(this).balance * 3)/100;
		uint256 help = (address(this).balance * 2)/100;

		// =============================================================================
			(bool DEV2, ) = 0x0AeaC6D1424EA6d0F87123A50CA5eEc9f16108c5.call{value: each}("");
			require(DEV2, "transaction failed");
			(bool DEV3, ) = 0xbCbb32C0caC8833061D6281e934B20bb93004255.call{value: each}("");
			require(DEV3, "transaction failed");
			(bool DEV1, ) = 0x8407A400dAdFd053199b1e67Fe75ba1e9d76D3A1.call{value: each}("");
			require(DEV1, "transaction failed");
			(bool DEV4, ) = 0xC608d2dD5AFA199a0c0E487Fdd669c1AD7459bE4.call{value: each}("");
			require(DEV4, "transaction failed");
			 (bool PRESENT, ) = 0xa3B17117F104e5965e98F07fe007784F6e3F3A2D.call{value: help}("");
			require(PRESENT, "transaction failed"); */
        (bool RACKS, ) = liquidity.call{value: address(this).balance}(""); // RESTO DEL BALANCE
        require(RACKS, "transaction failed");
        // =============================================================================
    }

    function setWhitelistPhase() public onlyAdmin {
        whitelistOn = !whitelistOn;
    }

    function addToWhitelist(address[] memory wallets) public onlyAdmin {
        for (uint256 i = 0; i < wallets.length; ++i)
            isWhitelisted[wallets[i]] = true;
    }

    function addAdmin(address _add) public onlyOwner {
        isAdmin[_add] = true;
    }

    function changeLiquidity(address _new) public onlyOwner {
        liquidity = _new;
    }
}
