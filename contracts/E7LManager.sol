// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IERC721Linkable.sol";

// Right now it will onl work if the parentAddress passed as parameter matches the parentAddress declared within the E7L.

contract E7LManager {
    /// Struct
    struct LinkedToken {
        uint256 id;
        address contractAddress;
    }

    /// State
    mapping(address => mapping(uint256 => LinkedToken[]))
        private parentToLinkedToken;

    ////////////////////////
    //  Logic Functions  //
    //////////////////////

    /**
     * @notice Link a batch of linkable tokens
     * @param parentAddress address of the parent contract
     * @param parentTokenId token Id of the parent contract
     * @param tokens must match LinkedToken struct properties
     */
    function linkTokens(
        address parentAddress,
        uint256 parentTokenId,
        LinkedToken[] calldata tokens
    ) external {
        require(tokens.length > 0, "E7LManager: invalid tokens argument");

        LinkedToken[] storage linkedTokens = parentToLinkedToken[parentAddress][
            parentTokenId
        ];

        unchecked {
            for (uint256 index = 0; index < tokens.length; ++index) {
                verifyOwnership(
                    parentAddress,
                    parentTokenId,
                    tokens[index].contractAddress,
                    tokens[index].id
                );

                linkedTokens.push(tokens[index]);

                IERC721Linkable e7l = IERC721Linkable(
                    tokens[index].contractAddress
                );

                require(
                    !e7l.tokenInfo(tokens[index].id).linked,
                    "E7LManager: token already linked"
                );

                // Change to receive parentAddress when multilinkale is ready
                e7l.linkToken(tokens[index].id, parentTokenId);
            }
        }
    }

    /**
     * @notice Syncs a batch of linked tokens
     * @param parentAddress address of the parent contract
     * @param parentTokenId token Id of the parent contract
     */
    function syncTokens(address parentAddress, uint256 parentTokenId) external {
        LinkedToken[] memory linkedTokens = getLinkedTokensFromParent(
            parentAddress,
            parentTokenId
        );
        uint256 linkedTokensLength = linkedTokens.length;

        require(linkedTokensLength > 0, "E7LManager: no tokens to sync");

        unchecked {
            for (uint256 index = 0; index < linkedTokensLength; ++index) {
                IERC721 parentContract = IERC721(parentAddress);
                IERC721Linkable e7lContract = IERC721Linkable(
                    linkedTokens[index].contractAddress
                );

                require(
                    e7lContract.ownerOf(linkedTokens[index].id) !=
                        parentContract.ownerOf(parentTokenId),
                    "E7LManager: token already synced"
                );

                // Change to receive parentAddress when multilinkale is ready
                e7lContract.syncToken(linkedTokens[index].id);
            }
        }
    }

    ////////////////////////
    //  Helper Functions //
    //////////////////////

    /**
     * Verify that the owner of the parent token is the owner of the child
     * token, and that the sender is the owner or approved
     * @param parentAddress address of the parent contract
     * @param parentTokenId token Id of the parent contract
     * @param childAddress address of the child contract
     * @param childTokenId token Id of the child contract
     */
    function verifyOwnership(
        address parentAddress,
        uint256 parentTokenId,
        address childAddress,
        uint256 childTokenId
    ) private view {
        IERC721 parentContract = IERC721(parentAddress);
        IERC721 childContract = IERC721(childAddress);

        require(
            childContract.ownerOf(childTokenId) ==
                parentContract.ownerOf(parentTokenId),
            "E7LManager: owners do not match"
        );

        require(
            childContract.getApproved(childTokenId) == msg.sender ||
                childContract.ownerOf(childTokenId) == msg.sender,
            "E7LManager: not owner or approved"
        );
    }

    ////////////////////////
    //  Getter Functions //
    //////////////////////

    /**
     * @notice Get all linked tokens associated to a parent
     * @param parentAddress address of the parent contract
     * @param parentTokenId token Id of the parent contract
     */
    function getLinkedTokensFromParent(
        address parentAddress,
        uint256 parentTokenId
    ) public view returns (LinkedToken[] memory) {
        return parentToLinkedToken[parentAddress][parentTokenId];
    }
}
