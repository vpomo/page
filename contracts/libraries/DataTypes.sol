// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";

library DataTypes {

    enum ActivityType { POST, MESSAGE, UP, DOWN, DEAL_GUARANTOR, DEAL_SELLER, DEAL_BUYER }

    struct DealMessage {
        string message;
        address sender;
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

    struct AddressUintsVote {
        string description;
        address creator;
        uint128 execMethodNumber;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint64[4] newValues;
        address user;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    struct AddressUintVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint128 value;
        address user;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    struct UintVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint128 newValue;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    struct BoolVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        bool newValue;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    struct AddressVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        address user;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        EnumerableSetUpgradeable.UintSet voteCommunities;
        bool active;
    }
}
