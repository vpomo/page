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

    event MakeDeal(address indexed creator, uint256 number);
    event ChangeDescription(uint256 dealId, string description);
    event ChangeTime(uint256 dealId, uint128 startTime, uint128 endTime);

    event StartApprove(uint256 dealId, address sender);
    event EndApprove(uint256 dealId, address sender);

    modifier onlyDealUser(uint256 dealId) {
        address sender = _msgSender();
        SafeDeal memory deal = deals[dealId];
        require(sender == deal.seller || sender == deal.buyer, "SafeDeal: wrong sender");
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
        require(_admin != address(0), "SafeDeal: wrong address");
        require(_calcUserRate != address(0), "SafeDeal: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        calcUserRate = IPageCalcUserRate(_calcUserRate);
    }

    function makeDeal(
        string memory desc,
        address seller,
        address buyer,
        uint128 startTime,
        uint128 endTime,
        uint256 amount
    ) external override {
        require(block.timestamp < startTime && startTime < endTime, "SafeDeal: wrong time");

        dealCount++;
        SafeDeal storage deal = deals[dealCount];
        deal.description = desc;
        deal.seller = seller;
        deal.buyer = buyer;
        deal.startTime = startTime;
        deal.endTime = endTime;
        deal.amount = amount;

        emit MakeDeal(_msgSender(), dealCount);
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

    function isFinished(uint256 dealId) external view override returns(bool) {
        SafeDeal memory deal = deals[dealId];
        return deal.endSellerApprove && deal.endBuyerApprove;
    }

}
