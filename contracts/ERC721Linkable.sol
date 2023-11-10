// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC721Linkable.sol";
import "./Linkable.sol";

abstract contract ERC721Linkable is ERC721, IERC721Linkable {
    // mapping from tokenId to LinkableToken struct
    mapping(uint256 => LinkableToken) private _tokensInfo;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {}

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721) returns (bool) {
        return
            interfaceId == type(IERC721Linkable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @notice Function that returns the token info for a specific tokenId
     */
    function tokenInfo(
        uint256 tokenId
    ) public view virtual override returns (LinkableToken memory) {
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");

        return _tokensInfo[tokenId];
    
    }

    function isLinked(uint256 tokenId) public view virtual returns (bool) {
        return address(_tokensInfo[tokenId].parentContract) != address(0);
    }

    function isSynced(uint256 tokenId) public view virtual returns (bool) {
        LinkableToken memory token = _tokensInfo[tokenId];

        return token.parentContract.ownerOf(token.parentTokenId) == _ownerOf(tokenId) ;
    }

    /**
     * @notice functions that links a tokenId form erc721linkable token to
     * another tokenId of the parent ERC721 contract
     * emits link event
     */
    function _safeLinkToken(
        uint256 tokenId,
        uint256 parentTokenId,
        IERC721 parentContract
    ) internal {
        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        require(
            _isAuthorized(this.ownerOf(tokenId), _msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        require(
            super.ownerOf(tokenId) == parentContract.ownerOf(parentTokenId),
            "ERC721Linkable: token owners do not match"
        );
        require(
            isLinked(tokenId) == false,
            "ERC721Linkable: token is already linked"
        );

        _linkToken(tokenId, parentTokenId, parentContract);
    }

    /**
     * @notice internal functions that links a tokenId form erc721linkable token to a tokenIf from the parent ERC721 contract
     */
    function _linkToken(
        uint256 tokenId,
        uint256 parentTokenId,
        IERC721 parentContract
    ) internal {
        LinkableToken storage token = _tokensInfo[tokenId];

        token.parentTokenId = parentTokenId;
        token.parentContract = parentContract;

        emit Link(tokenId, parentTokenId, parentContract);
    }

    /**
     * @notice functions that unlinks a linked tokenId from erc721linkable token
     * emits unlink event
     */
    function _safeUnlinkToken(uint256 tokenId) internal {
        require(
            _isAuthorized(this.ownerOf(tokenId), _msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        _unlinkToken(tokenId);
    }

    /**
     * @notice functions that unlinks a linked tokenId from erc721linkable token
     * emits unlink event
     */
    function _unlinkToken(uint256 tokenId) internal {
        LinkableToken storage token = _tokensInfo[tokenId];

        token.parentTokenId = 0;
        token.parentContract = IERC721(address(0));
        emit Unlink(tokenId);
    }

    /**
     * @notice Function that syncs the ownership of a token of the child contract
     * when linked token is transferred
     */
    function syncToken(uint256 tokenId) public virtual override {
        LinkableToken memory token = _tokensInfo[tokenId];

        require(
            isSynced(tokenId) == false,
            "ERC721Linkable: token already synced"
        );

        require(
            isLinked(tokenId),
            "ERC721Linkable: token not linked"
        );

        _transfer(
            _ownerOf(tokenId),
            token.parentContract.ownerOf(token.parentTokenId),
            tokenId
        );
    }

    /**
     * @dev override of _beforeTokenTransfer hook to only allow transfers to the owner
     * of the linked tokenId of the parent contract
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {


        if (_ownerOf(tokenId) != address(0)) {
            LinkableToken memory token = _tokensInfo[tokenId];

            if (isLinked(tokenId))
            {
                bool isTheLegitimateOwner = to ==
                    token.parentContract.ownerOf(token.parentTokenId);

                require (
                    isTheLegitimateOwner,
                    "ERC721Linkable: the 'to' address is not the legitimate owner"
                );
            } 
        }

        return super._update(to, tokenId, auth);
    }
}
