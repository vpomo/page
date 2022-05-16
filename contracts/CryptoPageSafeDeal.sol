// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageSafeDeal.sol";
import "./interfaces/ICryptoPageCalcUserRate.sol";


contract CryptoPageSafeDeal is
    Initializable,
    AccessControlUpgradeable,
    IPageSafeDeal
{

    IPageCalcUserRate public calcUserRate;

    uint256 public DEAL_FEE = 50;

    uint256 public dealCount;

    struct DealMessage {
        string message;
        uint256 writeTime;
    }

    struct SafeDeal {
        string description;
        address sideA;
        address sideB;
        address guarantor;
        uint256 amount;
        uint128 startTime;
        uint128 endTime;
        bool startApproveA;
        bool startApproveB;
        bool endApproveA;
        bool endApproveB;
        bool isIssue;
        bool isFinished;
        DealMessage[] messages;
    }

    mapping(uint256 => SafeDeal) private deals;

    event MakeDeal(address indexed creator, uint256 number);
    event ChangeDescription(uint256 dealId, string description);
    event ChangeTime(uint256 dealId, uint128 startTime, uint128 endTime);

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _admin Address of admin
     * @param _calcUserRate Address of calcUserRate
     */
    function initialize(address _admin, address _calcUserRate)
        public
        initializer
    {
        require(_admin != address(0), "SafeDeal: wrong address");
        require(_calcUserRate != address(0), "SafeDeal: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        calcUserRate = IPageCalcUserRate(_calcUserRate);
    }

    function makeDeal(
        string memory desc,
        address sideA,
        address sideB,
        uint128 startTime,
        uint128 endTime,
        uint256 amount
    ) external override {
        require(block.timestamp < startTime && startTime < endTime, "SafeDeal: wrong time");

        dealCount++;
        SafeDeal storage deal = deals[dealCount];
        deal.description = desc;
        deal.sideA = sideA;
        deal.sideB = sideB;
        deal.startTime = startTime;
        deal.endTime = endTime;
        deal.amount = amount;

        emit MakeDeal(_msgSender(), dealCount);
    }

    function changeDescription(uint256 dealId, string memory desc) external override {
        address sender = _msgSender();
        SafeDeal storage deal = deals[dealCount];
        require(sender == deal.sideA || sender == deal.sideB, "SafeDeal: wrong sender");
        deal.description = desc;

        emit ChangeDescription(dealId, desc);
    }

    function changeTime(uint256 dealId, uint128 startTime, uint128 endTime) external override {
        address sender = _msgSender();
        SafeDeal storage deal = deals[dealCount];
        require(sender == deal.sideA || sender == deal.sideB, "SafeDeal: wrong sender");
        if(startTime > 0) {
            require(block.timestamp < startTime, "SafeDeal: wrong start time");
            deal.startTime = startTime;
        }

        if(endTime > 0) {
            require(block.timestamp < deal.startTime && deal.startTime < endTime, "SafeDeal: wrong end time");
            deal.endTime = endTime;
        }

        emit ChangeTime(dealId, startTime, endTime);
    }


}
