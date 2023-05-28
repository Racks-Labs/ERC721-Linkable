// SPDX-License-Identifier: UNLICENSED
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
    )
        public
        view
        virtual
        override(IERC165Upgradeable, ERC721Upgradeable)
        returns (bool)
    {
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
        require(_exists(tokenId) == true, "ERC721: invalid token ID");
        return _tokensInfo[tokenId];
    }

    /**
     * @notice functions that links a tokenId form erc721linkable token to
     * another tokenId of the parent ERC721 contract
     * emits link event
     */
    function _linkToken(
        uint256 tokenId,
        uint256 parentTokenId,
        IERC721 parentContract
    ) internal {
        LinkableToken storage token = _tokensInfo[tokenId];

        require(
            super.ownerOf(tokenId) == parentContract.ownerOf(parentTokenId),
            "ERC721LinkableUpgradeable: token owners do not match"
        );
        require(
            token.parentContract == IERC721(address(0)),
            "ERC721LinkableUpgradeable: token is already linked"
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        token.parentTokenId = parentTokenId;
        token.parentContract = parentContract;
        emit Link(tokenId, parentTokenId, parentContract);
    }

    /**
     * @notice Function thath syncs the ownership of a token of the child contract
     * when linked token is transfered
     */
    function syncToken(uint256 tokenId) public virtual override {
        LinkableToken memory token = _tokensInfo[tokenId];

        require(
            super.ownerOf(tokenId) !=
                token.parentContract.ownerOf(token.parentTokenId),
            "ERC721LinkableUpgradeable: token already synced"
        );
        _safeTransfer(
            super.ownerOf(tokenId),
            token.parentContract.ownerOf(token.parentTokenId),
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

        LinkableToken memory token = _tokensInfo[tokenId];

        if (_exists(tokenId)) {
            require(
                token.parentContract != IERC721(address(0)),
                "ERC721LinkableUpgradeable: cannot transfer token because is not linked"
            );
            require(
                from == super.ownerOf(tokenId) &&
                    to == token.parentContract.ownerOf(token.parentTokenId),
                "ERC721LinkableUpgradeable: invalid address. Use syncToken()"
            );
        }
    }
}
