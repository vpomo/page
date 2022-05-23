// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageSafeDeal.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCalcUserRate.sol";
import "./interfaces/ICryptoPageBank.sol";

import {DataTypes} from './libraries/DataTypes.sol';

contract PageSafeDeal is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageSafeDeal
{

    IPageCalcUserRate public calcUserRate;
    IPageToken public token;
    IPageBank public bank;

    uint256 public GUARANTOR_FEE = 0.02 ether;

    uint256 public dealCount;

    mapping(uint256 => DataTypes.SafeDeal) private deals;

    event SetToken(address indexed token);

    event MakeDeal(address indexed creator, uint256 number, bool isEth, uint256 amount);
    event FinishDeal(address indexed guarantor, uint256 number, uint256 amount);
    event CancelDeal(address indexed guarantor, uint256 number, uint256 amount);

    event ChangeDescription(uint256 dealId, string description);
    event ChangeTime(uint256 dealId, uint128 startTime, uint128 endTime);
    event AddMessage(uint256 dealId, address sender, string message);

    event StartApprove(uint256 dealId, address sender);
    event EndApprove(uint256 dealId, address sender);
    event SetIssue(uint256 dealId, address sender);
    event ClearIssue(uint256 dealId, address sender);

    modifier onlyDealUser(uint256 dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal memory deal = deals[dealId];
        require(sender == deal.seller || sender == deal.buyer, "SafeDeal: wrong deal user");
        _;
    }

    modifier onlyGuarantor(uint256 dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal memory deal = deals[dealId];
        require(sender == deal.guarantor, "SafeDeal: wrong guarantor");
        _;
    }

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _admin Address of admin
     * @param _calcUserRate Address of calcUserRate
     */
    function initialize(address _admin, address _calcUserRate, address _bank) public initializer {
        __Ownable_init();
        require(_admin != address(0), "SafeDeal: wrong address");
        require(_calcUserRate != address(0), "SafeDeal: wrong address");
        require(_bank != address(0), "SafeDeal: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        calcUserRate = IPageCalcUserRate(_calcUserRate);
        bank = IPageBank(_bank);
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() external pure override returns (string memory) {
        return "1";
    }

    /**
     * @dev Changes the address of the token.
     *
     * @param newToken New address value
     */
    function setToken(address newToken) external override onlyOwner {
        token = IPageToken(newToken);
        emit SetToken(newToken);
    }

    function makeDeal(
        string memory desc,
        address buyer,
        address guarantor,
        uint128 startTime,
        uint128 endTime,
        uint256 amount,
        bool isEth
    ) external payable override {
        address seller = _msgSender();
        require(block.timestamp < startTime && startTime < endTime, "SafeDeal: wrong time");
        require(buyer != address(0) && guarantor != address(0), "SafeDeal: wrong address");
        require(guarantor != buyer && guarantor != seller, "SafeDeal: wrong guarantor address");

        dealCount++;
        DataTypes.SafeDeal storage deal = deals[dealCount];

        require(amount > 0, "SafeDeal: wrong amount");
        if (isEth) {
            require(msg.value == amount, "SafeDeal: wrong transfer ether");
            deal.isEth = true;
        } else {
            require(msg.value == 0, "SafeDeal: wrong msg.value");
            require(token.transferFrom(seller, address(this), amount), "SafeDeal: wrong transfer for seller");
        }
        require(token.transferFrom(seller, guarantor, getGuarantorBonus()), "SafeDeal: wrong transfer for guarantor");

        deal.description = desc;
        deal.seller = seller;
        deal.buyer = buyer;
        deal.guarantor = guarantor;
        deal.startTime = startTime;
        deal.endTime = endTime;
        deal.amount = amount;

        emit MakeDeal(_msgSender(), dealCount, isEth, amount);
    }

    function changeDescription(uint256 dealId, string memory desc) external override onlyDealUser(dealId) {
        DataTypes.SafeDeal storage deal = deals[dealCount];
        deal.description = desc;

        emit ChangeDescription(dealId, desc);
    }

    function changeTime(uint256 dealId, uint128 startTime, uint128 endTime) external override onlyDealUser(dealId) {
        DataTypes.SafeDeal storage deal = deals[dealId];
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

    function makeStartApprove(uint256 dealId) external override onlyDealUser(dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(!isIssue(dealId), "SafeDeal: there is an issue here");

        if(sender == deal.seller) {
            require(!deal.startSellerApprove, "SafeDeal: wrong approve");
            deal.startSellerApprove = true;
        }
        if(sender == deal.buyer) {
            require(!deal.startBuyerApprove, "SafeDeal: wrong approve");
            deal.startBuyerApprove = true;
        }

        emit StartApprove(dealId, sender);
    }

    function makeEndApprove(uint256 dealId) external override onlyDealUser(dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(block.timestamp > deal.endTime, "SafeDeal: wrong start time");
        require(!isIssue(dealId), "SafeDeal: there is an issue here");
        require(isStartApproved(dealId), "SafeDeal: wrong start approve");

        if(sender == deal.seller) {
            require(!deal.endSellerApprove, "SafeDeal: wrong approve");
            deal.endSellerApprove = true;
        }
        if(sender == deal.buyer) {
            require(!deal.endBuyerApprove, "SafeDeal: wrong approve");
            deal.endBuyerApprove = true;
        }

        emit EndApprove(dealId, sender);
    }

    function addMessage(uint256 dealId, string memory message) public override onlyDealUser(dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal storage deal = deals[dealId];
        DataTypes.DealMessage memory dealMessage = DataTypes.DealMessage(message, block.timestamp);
        deal.messages.push(dealMessage);

        emit AddMessage(dealId, sender, message);
    }

    function setIssue(uint256 dealId, string memory message) external override onlyDealUser(dealId) {
        address sender = _msgSender();
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(!isFinished(dealId) && !isIssue(dealId), "SafeDeal: already finished");
        deal.isIssue = true;
        addMessage(dealId, message);

        emit SetIssue(dealId, sender);
    }

    function clearIssue(uint256 dealId) external override onlyGuarantor(dealId) {
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(isIssue(dealId), "SafeDeal: not issue");
        deal.isIssue = false;

        emit ClearIssue(dealId, deal.guarantor);
    }

    function cancelDeal(uint256 dealId) external override onlyGuarantor(dealId) {
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(isIssue(dealId) && !isFinished(dealId), "SafeDeal: not issue");
        uint256 amount = deal.amount;
        deal.isFinished = true;
        transferAsset(deal.isEth, deal.seller, amount);
        calcUserRate.addDealActivity(deal.guarantor, DataTypes.ActivityType.DEAL_GUARANTOR);
        emit CancelDeal(deal.guarantor, dealId, amount);
    }

    function finishDeal(uint256 dealId) external override onlyGuarantor(dealId) {
        DataTypes.SafeDeal storage deal = deals[dealId];
        require(
            isStartApproved(dealId) &&
            isEndApproved(dealId) &&
            !isIssue(dealId) &&
            !isFinished(dealId),
            "SafeDeal: already finished"
        );
        uint256 amount = deal.amount;
        deal.isFinished = true;
        transferAsset(deal.isEth, deal.buyer, amount);

        calcUserRate.addDealActivity(deal.guarantor, DataTypes.ActivityType.DEAL_GUARANTOR);
        calcUserRate.addDealActivity(deal.seller, DataTypes.ActivityType.DEAL_SELLER);
        calcUserRate.addDealActivity(deal.buyer, DataTypes.ActivityType.DEAL_BUYER);

        emit FinishDeal(deal.guarantor, dealId, amount);
    }

    function readCommonDeal(uint256 dealId) external view override returns(
        string memory description,
        address seller,
        address buyer,
        address guarantor,
        uint256 amount,
        uint128 startTime,
        uint128 endTime
    ) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        description = deal.description;
        seller = deal.seller;
        buyer = deal.buyer;
        guarantor = deal.guarantor;
        amount = deal.amount;
        startTime = deal.startTime;
        endTime = deal.endTime;
    }

    function getGuarantorBonus() public view override returns(uint256 amount) {
        amount = GUARANTOR_FEE * bank.getWETHPagePrice();
    }

    function readApproveDeal(uint256 dealId) external view override returns(
        bool startSellerApprove,
        bool startBuyerApprove,
        bool endSellerApprove,
        bool endBuyerApprove
    ) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        startSellerApprove = deal.startSellerApprove;
        startBuyerApprove = deal.startBuyerApprove;
        endSellerApprove = deal.endSellerApprove;
        endBuyerApprove = deal.endBuyerApprove;
    }

    function readBoolDeal(uint256 dealId) external view override returns(
        bool issue,
        bool eth,
        bool finished
    ) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        issue = deal.isIssue;
        eth = deal.isEth;
        finished = deal.isFinished;
    }

    function readMessagesDeal(uint256 dealId) external view override returns(
        DataTypes.DealMessage[] memory messages
    ) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        messages = deal.messages;
    }

    function isStartApproved(uint256 dealId) public view override returns(bool) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        return deal.startSellerApprove && deal.startBuyerApprove;
    }

    function isEndApproved(uint256 dealId) public view override returns(bool) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        return deal.endSellerApprove && deal.endBuyerApprove;
    }

    function isFinished(uint256 dealId) public view override returns(bool) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        return deal.isFinished;
    }

    function isIssue(uint256 dealId) public view override returns(bool) {
        DataTypes.SafeDeal memory deal = deals[dealId];
        return deal.isIssue;
    }

    function currentTime() public view override returns(uint256) {
        return block.timestamp;
    }

    function transferAsset(bool isEth, address recipient, uint256 amount) private {
        if (isEth) {
            require(address(this).balance >= amount, "SafeDeal: wrong ether balance");
            require(payable(recipient).send(amount), "SafeDeal: wrong transfer ether");
        } else {
            require(token.transfer(recipient,  amount), "SafeDeal: wrong transfer of tokens");
        }
    }
}
