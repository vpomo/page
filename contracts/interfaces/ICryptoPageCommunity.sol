// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IPageCommunity {

    function version() external pure returns (string memory);

    function addCommunity(string memory desc) external;

    function addModerator(uint256 communityId, address moderator) external;

    function removeModerator(uint256 communityId, address moderator) external;

    function join(uint256 communityId) external;

    function quit(uint256 communityId) external;

    function writePost(
        uint256 communityId,
        string memory ipfsHash,
        address owner
    ) external;

    function readPost(uint256 postId) external returns(
        string memory ipfsHash,
        address creator,
        address owner,
        uint64 upCount,
        uint64 downCount,
        uint128 price,
        uint256 commentCount,
        address[] memory upDownUsers,
        bool isView
    );

    function burnPost(uint256 postId) external;

    function setVisibilityPost(uint256 postId, bool newVisible) external;

    function getPostPrice(uint256 postId) external view returns (uint256);

    function getPostsIdsByCommunityId(uint256 communityId) external view returns (uint256[] memory);

    function writeComment(
        uint256 postId,
        string memory ipfsHash,
        bool isUp,
        bool isDown,
        address owner
    ) external;

    function readComment(uint256 postId, uint256 commentId) external returns(
        string memory ipfsHash,
        address creator,
        address owner,
        uint128 price,
        bool isUp,
        bool isDown,
        bool isView
    );

    function burnComment(uint256 postId, uint256 commentId) external;

    function setVisibilityComment(
        uint256 postId,
        uint256 commentId,
        bool newVisible
    ) external;

    function getCommentCount(uint256 postId) external returns(uint256);

    function isCommunityCreator(uint256 communityId, address user) external returns(bool);

    function isCommunityUser(uint256 communityId, address user) external returns(bool);

    function isCommunityModerator(uint256 communityId, address user) external returns(bool);

    function getCommunityIdByPostId(uint256 postId) external returns(uint256);

    function isUpDownUser(uint256 postId, address user) external returns(bool);

    function isActiveCommunityByPostId(uint256 postId) external returns(bool);

}