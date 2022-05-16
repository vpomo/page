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
