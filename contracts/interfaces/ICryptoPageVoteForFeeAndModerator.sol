// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;


interface IPageVoteForFeeAndModerator {

    function version() external pure returns (string memory);

    function createVote(
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint128 methodNumber,
        uint64[4] memory values,
        address user
    ) external;

    function setMinDuration(uint128 minDuration) external;

    function putVote(uint256 communityId, uint256 index, bool isYes) external;

    function executeVote(uint256 communityId, uint256 index) external;

    function readVote(uint256 communityId, uint256 index) external view returns(
        string memory description,
        address creator,
        uint128 execMethodNumber,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint64[4] memory newValues,
        address user,
        address[] memory voteUsers,
        bool active
    );

    function readVotesCount(uint256 communityId) external view returns(uint256 count);
}
