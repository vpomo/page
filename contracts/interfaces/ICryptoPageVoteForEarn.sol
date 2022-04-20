// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;


interface IPageVoteForEarn {

    function version() external pure returns (string memory);

    function createPrivacyAccessPriceVote (
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint256 newPrice
    ) external;

    function setMinDuration(uint128 minDuration) external;

    function putPrivacyAccessPriceVote(uint256 communityId, uint256 index, bool isYes) external;

    function executePrivacyAccessPriceVote(uint256 communityId, uint256 index) external;

    function readPrivacyAccessPriceVote(uint256 communityId, uint256 index) external view returns(
        string memory description,
        address creator,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint128 newPrice,
        address[] memory voteUsers,
        bool active
    );

    function readPrivacyAccessPriceVotesCount(uint256 communityId) public view returns(uint256 count);
}
