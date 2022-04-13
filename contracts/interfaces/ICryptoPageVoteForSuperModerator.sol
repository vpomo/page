// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;


interface IPageVoteForFeeAndModerator {

    function version() external pure returns (string memory);

    function createVote(
        uint256 communityId,
        string memory description,
        uint128 duration,
        address user
    ) external;

    function setMinDuration(uint128 minDuration) external;

    function putVote(uint256 communityId, uint256 index, bool isYes) external;

    function executeVote(uint256 communityId, uint256 index) external;

    function readVote(uint256 index) external override view returns(
        string memory description,
        address creator,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        address user,
        address[] memory voteUsers,
        uint256[] memory voteCommunities,
        bool active
    );

    function readVotesCount() external view returns(uint256 count);
}
