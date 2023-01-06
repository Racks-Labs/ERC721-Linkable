// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC721Linkable.sol";
import "./Linkable.sol";

abstract contract ERC721Linkable is ERC721, IERC721Linkable {
    // immutable address of the parent contract
    IERC721 public immutable parentContract;

    // mapping from tokenId to LinkableToken struct
    mapping(uint256 => LinkableToken) private _tokensInfo;

    constructor(
        string memory _name,
        string memory _symbol,
        address _parentContract
    ) ERC721(_name, _symbol) {
        parentContract = IERC721(_parentContract);
    }

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Linkable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @notice Function that returns the token info for a specific tokenId
     */
    function tokenInfo(uint256 tokenId)
        public
        view
        virtual
        override
        returns (LinkableToken memory)
    {
        require(_exists(tokenId) == true, "ERC721: invalid token ID");
        return _tokensInfo[tokenId];
    }

    /**
     * @notice functions that links a tokenId form erc721linkable token to
     * another tokenId of the parent ERC721 contract
     * emits link event
     */
    function linkToken(uint256 tokenId, uint256 parentTokenId) external {
        LinkableToken storage token = _tokensInfo[tokenId];

        require(
            super.ownerOf(tokenId) == parentContract.ownerOf(parentTokenId),
            "ERC721Linkable: token owners do not match"
        );
        require(!token.linked, "ERC721Linkable: token is already linked");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        token.parentTokenId = parentTokenId;
        token.linked = true;
        emit Link(tokenId, parentTokenId);
    }

    /**
     * @notice Function thath syncs the ownership of a token of the child contract
     * when linked token is transfered
     */
    function syncToken(uint256 tokenId) public virtual override {
        require(
            super.ownerOf(tokenId) !=
                parentContract.ownerOf(_tokensInfo[tokenId].parentTokenId),
            "ERC721Linkable: token already synced"
        );
        _safeTransfer(
            super.ownerOf(tokenId),
            parentContract.ownerOf(_tokensInfo[tokenId].parentTokenId),
            tokenId,
            ""
        );
    }

    /**
     * @dev override of _beforeTokenTransfer hook to only allow transfers to the owner
     * of the linked tokenId of the parent contract
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        if (_exists(tokenId)) {
            require(
                _tokensInfo[tokenId].linked == true,
                "ERC721Linkable: cannot transfer token because is not linked"
            );
            require(
                from == super.ownerOf(tokenId) &&
                    to ==
                    parentContract.ownerOf(_tokensInfo[tokenId].parentTokenId),
                "ERC721Linkable: invalid address. Use syncToken()"
            );
        }
    }
}
