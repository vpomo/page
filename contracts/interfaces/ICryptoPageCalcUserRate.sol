// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {DataTypes} from '../libraries/DataTypes.sol';

interface IPageCalcUserRate {

    function version() external pure returns (string memory);

    function checkActivity(uint256 communityId, address user, DataTypes.ActivityType activityType) external returns(int256 resultPercent);

    function calcPercent(address user, uint256 baseTokenId) external view returns(int256 resultPercent);

    function getUserActivity(uint256 communityId, address user) external view returns(
        uint64 messageCount,
        uint64 postCount,
        uint64 upCount,
        uint64 downCount
    );

    function getUserRedeemed(uint256 communityId, address user) external view returns(
        uint64[3] memory messageCount,
        uint64[3] memory postCount,
        uint64[2] memory upCount,
        uint64[2] memory downCount
    );

    function setInterestAdjustment(uint256[10] calldata values) external;
}
