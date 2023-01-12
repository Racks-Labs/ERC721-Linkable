// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IERC721Linkable.sol";
import "./Linkable.sol";

// Right now it will onl work if the parentAddress passed as parameter matches the parentAddress declared within the E7L.

/// @notice Errors
error E7LManager_invalidArgument();
error E7LManager_ownersDoNotMatch();
error E7LManager_notOwnerOrApproved();
error E7LManager_tokenAlreadyLinked();
error E7LManager_tokenAlreadySynced();
error E7LManager_noTokensLinked();

contract E7LManager {
    /// @notice Struct
    struct LinkedToken {
        uint256 id;
        address contractAddress;
    }

    /// @notice State
    mapping(address => mapping(uint256 => LinkedToken[]))
        private parentToLinkedToken;

    ////////////////////////
    //  Logic Functions  //
    //////////////////////

    /**
     * @notice Link a batch of linkable tokens
     * @param tokens must match LinkedToken struct properties
     */
    function linkTokens(
        address parentAddress,
        uint256 parentId,
        LinkedToken[] calldata tokens
    ) external {
        if (tokens.length <= 0) revert E7LManager_invalidArgument();

        unchecked {
            for (uint256 index = 0; index < tokens.length; ++index) {
                verifyOwnershipOnLink(
                    parentAddress,
                    parentId,
                    tokens[index].contractAddress,
                    tokens[index].id
                );
                parentToLinkedToken[parentAddress][parentId].push(
                    tokens[index]
                );
                IERC721Linkable e7l = IERC721Linkable(
                    tokens[index].contractAddress
                );
                if ((e7l.tokenInfo(tokens[index].id)).linked)
                    revert E7LManager_tokenAlreadyLinked();
                // Change to receive parentAddress when multilinkale is ready
                e7l.linkToken(tokens[index].id, parentId);
            }
        }
    }

    // @notice Syncs a batch of linked tokens
    function syncTokens(address parentAddress, uint256 parentId) external {
        LinkedToken[] memory linkedTokens = getLinkedTokensFromParent(
            parentAddress,
            parentId
        );
        uint256 linkedTokensLength = linkedTokens.length;
        if (linkedTokensLength <= 0) revert E7LManager_noTokensLinked();

        unchecked {
            for (uint256 index = 0; index < linkedTokensLength; ++index) {
                verifyOwnershipOnSync(
                    parentAddress,
                    parentId,
                    linkedTokens[index].contractAddress,
                    linkedTokens[index].id
                );
                IERC721Linkable e7l = IERC721Linkable(
                    linkedTokens[index].contractAddress
                );
                // Change to receive parentAddress when multilinkale is ready
                e7l.syncToken(linkedTokens[index].id);
            }
        }
    }

    ////////////////////////
    //  Helper Functions //
    //////////////////////

    /// @notice Verify ownership of the nfts before linking
    function verifyOwnershipOnLink(
        address parentAddress,
        uint256 parentId,
        address childAddress,
        uint256 childtId
    ) private view {
        IERC721 parentContract = IERC721(parentAddress);
        IERC721 childContract = IERC721(childAddress);

        if (childContract.ownerOf(childtId) != parentContract.ownerOf(parentId))
            revert E7LManager_ownersDoNotMatch();
        if (
            childContract.getApproved(childtId) != msg.sender &&
            childContract.ownerOf(childtId) != msg.sender
        ) revert E7LManager_notOwnerOrApproved();
    }

    /// @notice Verify that ownership does not match before syncing
    function verifyOwnershipOnSync(
        address parentAddress,
        uint256 parentId,
        address childAddress,
        uint256 childtId
    ) private view {
        IERC721 parentContract = IERC721(parentAddress);
        IERC721 childContract = IERC721(childAddress);

        if (childContract.ownerOf(childtId) == parentContract.ownerOf(parentId))
            revert E7LManager_tokenAlreadySynced();
    }

    ////////////////////////
    //  Getter Functions //
    //////////////////////

    /**
     * @notice Get all linked tokens associated to a parent
     * @param parentAddress
     * @param parentTokenId
     */
    function getLinkedTokensFromParent(
        address parentAddress,
        uint256 parentToken
    ) public view returns (LinkedToken[] memory) {
        return parentToLinkedToken[parentAddress][parentTokenId];
    }
}
