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

    struct SafeDeal {
        string description;
        string[] messages;
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
    }

    mapping(uint256 => SafeDeal) private deals;

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
        require(_admin != address(0), "PageBank: wrong address");
        require(_calcUserRate != address(0), "PageBank: wrong address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        calcUserRate = IPageCalcUserRate(_calcUserRate);
    }



}
