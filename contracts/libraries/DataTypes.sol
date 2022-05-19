// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

library DataTypes {

    enum ActivityType { POST, MESSAGE, UP, DOWN, DEAL_GUARANTOR, DEAL_SELLER, DEAL_BUYER }

    struct DealMessage {
        string message;
        uint256 writeTime;
    }

    struct SafeDeal {
        string description;
        address seller;
        address buyer;
        address guarantor;
        uint256 amount;
        uint128 startTime;
        uint128 endTime;
        bool startSellerApprove;
        bool startBuyerApprove;
        bool endSellerApprove;
        bool endBuyerApprove;
        bool isIssue;
        bool isEth;
        bool isFinished;
        DealMessage[] messages;
    }
}
