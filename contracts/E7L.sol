// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./ERC721Linkable.sol";

contract E7L is ERC721Linkable {
    using Strings for uint256;

    uint256 public maxSupply;
    uint256 public totalSupply;

    string public baseURI;
    string public baseExtension = ".json";

    address public owner;
    mapping(address => bool) public isAdmin;

    modifier onlyOwner() {
        require(msg.sender == owner, "E7L: Not owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || isAdmin[msg.sender] == true, "E7L: Not admin");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        address _parentContract,
        string memory _baseURI
    ) ERC721Linkable(_name, _symbol, _parentContract) {
        owner = tx.origin;
        baseURI = _baseURI;
    }

    //PUBLIC
    function mint(uint256 tokenId) public {
        _safeMint(msg.sender, tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension))
            : "";
    }

    //ONLY ADMIN
    function setBaseURI(string memory baseURI_) public onlyAdmin {
        baseURI = baseURI_;
    }

    function setAdmin(address wallet_, bool is_) public onlyOwner {
        require(isAdmin[wallet_] != is_, "E7L: Admin already set");
        isAdmin[wallet_] = is_;
    }
}
