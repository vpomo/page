// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import {DataTypes} from '../libraries/DataTypes.sol';

interface IPageSafeDeal {

    function version() external pure returns (string memory);

    function setToken(address newToken) external;

    function makeDeal(
        string memory desc,
        address buyer,
        address guarantor,
        uint128 startTime,
        uint128 endTime,
        uint256 amount,
        bool isEth
    ) external payable;

    function changeDescription(uint256 dealId, string memory desc) external;

    function changeTime(uint256 dealId, uint128 startTime, uint128 endTime) external;

    function makeStartApprove(uint256 dealId) external;

    function makeEndApprove(uint256 dealId) external;

    function addMessage(uint256 dealId, string memory message) external;

    function setIssue(uint256 dealId, string memory message) external;

    function clearIssue(uint256 dealId) external;

    function cancelDeal(uint256 dealId) external;

    function finishDeal(uint256 dealId) external;

    function readCommonDeal(uint256 dealId) external view returns(
        string memory description,
        address seller,
        address buyer,
        address guarantor,
        uint256 amount,
        uint128 startTime,
        uint128 endTime
    );

    function readApproveDeal(uint256 dealId) external view returns(
        bool startSellerApprove,
        bool startBuyerApprove,
        bool endSellerApprove,
        bool endBuyerApprove
    );

    function readBoolDeal(uint256 dealId) external view returns(
        bool isIssue,
        bool isEth,
        bool isFinished
    );

    function readMessagesDeal(uint256 dealId) external view returns(
        DataTypes.DealMessage[] memory messages
    );

    function isStartApproved(uint256 dealId) external view returns(bool);

    function isEndApproved(uint256 dealId) external view returns(bool);

    function isFinished(uint256 dealId) external view returns(bool);

    function isIssue(uint256 dealId) external view returns(bool);

    function currentTime() external view returns(uint256);

}
