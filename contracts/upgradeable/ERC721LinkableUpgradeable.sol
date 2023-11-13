// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IERC721LinkableUpgradeable.sol";
import "../Linkable.sol";

abstract contract ERC721LinkableUpgradeable is
    ERC721Upgradeable,
    IERC721LinkableUpgradeable
{
    // mapping from tokenId to LinkableToken struct
    mapping(uint256 => LinkableToken) private _tokensInfo;

    function __ERC721Linkable_init() internal onlyInitializing {}

    /**
     * @notice See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165, ERC721Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721LinkableUpgradeable).interfaceId ||
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

        return
            token.parentContract.ownerOf(token.parentTokenId) ==
            _ownerOf(tokenId);
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
        require(
            ERC721(address(parentContract)).supportsInterface(
                type(IERC721).interfaceId
            ),
            "ERC721LinkableUpgradeable: parent contract does not support ERC721 interface"
        );

        require(_ownerOf(tokenId) != address(0), "ERC721: invalid token ID");
        require(
            _isAuthorized(this.ownerOf(tokenId), _msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );
        require(
            super.ownerOf(tokenId) == parentContract.ownerOf(parentTokenId),
            "ERC721LinkableUpgradeable: token owners do not match"
        );
        require(
            isLinked(tokenId) == false,
            "ERC721LinkableUpgradeable: token is already linked"
        );

        _linkToken(tokenId, parentTokenId, parentContract);
    }

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
    function _unlinkToken(uint256 tokenId) internal {
        LinkableToken storage token = _tokensInfo[tokenId];

        require(
            _isAuthorized(this.ownerOf(tokenId), _msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

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
            "ERC721LinkableUpgradeable: token already synced"
        );

        require(isLinked(tokenId), "ERC721LinkableUpgradeable: token not linked");

        address ownerOfParentToken = token.parentContract.ownerOf(
            token.parentTokenId
        );
        address ownerOfToken = _ownerOf(tokenId);

        if (ownerOfParentToken == address(0)) {
            /// @dev use burn instead of transfer to have a correct accounting of
            /// the total supply and burned tokens
            _burn(tokenId);
            delete _tokensInfo[tokenId];
        } else {
            _transfer(ownerOfToken, ownerOfParentToken, tokenId);
        }
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

            if (isLinked(tokenId)) {
                bool isTheLegitimateOwner = to ==
                    token.parentContract.ownerOf(token.parentTokenId);

                require(
                    isTheLegitimateOwner,
                    "ERC721LinkableUpgradeable: the 'to' address is not the legitimate owner"
                );
            }
        }

        return super._update(to, tokenId, auth);
    }
}
