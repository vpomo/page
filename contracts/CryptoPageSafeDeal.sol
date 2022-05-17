// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageSafeDeal.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCalcUserRate.sol";


contract CryptoPageSafeDeal is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageSafeDeal
{

    IPageCalcUserRate public calcUserRate;
    IPageToken public token;

    uint256 public DEAL_FEE = 50;

    uint256 public dealCount;

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
        DealMessage[] messages;
    }

    mapping(uint256 => SafeDeal) private deals;

    event MakeDeal(address indexed creator, uint256 number, uint256 amount);
    event MakeFinish(address indexed creator, uint256 number, uint256 amount);
    event ChangeDescription(uint256 dealId, string description);
    event ChangeTime(uint256 dealId, uint128 startTime, uint128 endTime);
    event AddMessage(uint256 dealId, address sender, string message);

    event StartApprove(uint256 dealId, address sender);
    event EndApprove(uint256 dealId, address sender);
    event SetIssue(uint256 dealId, address sender);
    event ClearIssue(uint256 dealId, address sender);

    modifier onlyDealUser(uint256 dealId) {
        address sender = _msgSender();
        SafeDeal memory deal = deals[dealId];
        require(sender == deal.seller || sender == deal.buyer, "SafeDeal: wrong deal user");
        _;
    }

    modifier onlyGuarantor(uint256 dealId) {
        address sender = _msgSender();
        SafeDeal memory deal = deals[dealId];
        require(sender == deal.guarantor, "SafeDeal: wrong guarantor");
        _;
    }

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
        __Ownable_init();
        require(_admin != address(0), "SafeDeal: wrong address");
        require(_calcUserRate != address(0), "SafeDeal: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        calcUserRate = IPageCalcUserRate(_calcUserRate);
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
        uint256 amount
    ) external override {
        address seller = _msgSender();
        require(block.timestamp < startTime && startTime < endTime, "SafeDeal: wrong time");
        require(buyer != address(0) && guarantor != address(0), "SafeDeal: wrong address");
        require(guarantor != buyer && guarantor != seller, "SafeDeal: wrong guarantor address");

        require(amount > 0, "SafeDeal: wrong amount");
        require(token.transferFrom(seller, address(this), amount), "SafeDeal: wrong transfer of tokens");

        dealCount++;
        SafeDeal storage deal = deals[dealCount];
        deal.description = desc;
        deal.seller = seller;
        deal.buyer = buyer;
        deal.guarantor = guarantor;
        deal.startTime = startTime;
        deal.endTime = endTime;
        deal.amount = amount;

        emit MakeDeal(_msgSender(), dealCount, amount);
    }

    function changeDescription(uint256 dealId, string memory desc) external override onlyDealUser(dealId) {
        SafeDeal storage deal = deals[dealCount];
        deal.description = desc;

        emit ChangeDescription(dealId, desc);
    }

    function changeTime(uint256 dealId, uint128 startTime, uint128 endTime) external override onlyDealUser(dealId) {
        SafeDeal storage deal = deals[dealId];
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
        SafeDeal storage deal = deals[dealId];
        require(block.timestamp < deal.startTime, "SafeDeal: wrong start time");
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
        SafeDeal storage deal = deals[dealId];
        require(block.timestamp > deal.endTime, "SafeDeal: wrong start time");
        require(!isIssue(dealId), "SafeDeal: there is an issue here");

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

    function addMessage(uint256 dealId, string memory message) external override onlyDealUser(dealId) {
        address sender = _msgSender();
        SafeDeal storage deal = deals[dealId];
        DealMessage dealMessage = DealMessage(message, block.timestamp);
        deal.messages.push(dealMessage);

        emit AddMessage(dealId, sender, message);
    }

    function setIssue(uint256 dealId) external override onlyDealUser(dealId) {
        address sender = _msgSender();
        SafeDeal storage deal = deals[dealId];
        require(!isFinished(dealId) && !isIssue(dealId), "SafeDeal: already finished");
        deal.isIssue = true;

        emit SetIssue(dealId, sender);
    }

    function clearIssue(uint256 dealId) external override onlyGuarantor(dealId) {
        SafeDeal storage deal = deals[dealId];
        require(isIssue(dealId), "SafeDeal: not issue");
        deal.isIssue = false;

        emit ClearIssue(dealId, deal.guarantor);
    }

    function finish(uint256 dealId) external override onlyGuarantor(dealId) {
        SafeDeal storage deal = deals[dealId];
        require(isFinished(dealId) && !isIssue(dealId), "SafeDeal: already finished");
        emit MakeFinish(dealId, deal.guarantor, deal.amount);
        deal.amount = 0;
        require(token.transfer(deal.buyer,  deal.amount), "SafeDeal: wrong transfer of tokens");
    }

    function isFinished(uint256 dealId) public view override returns(bool) {
        SafeDeal memory deal = deals[dealId];
        return deal.endSellerApprove && deal.endBuyerApprove;
    }

    function isIssue(uint256 dealId) public view override returns(bool) {
        SafeDeal memory deal = deals[dealId];
        return deal.isIssue;
    }

}
