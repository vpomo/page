// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "../interfaces/ICryptoPageBank.sol";
import "../interfaces/ICryptoPageCommunity.sol";
import "../interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageCalcUserRate.sol";

/// @title The contract calculates rates of users
/// @author Crypto.Page Team
/// @notice
/// @dev 
contract PageCalcUserRate is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageCalcUserRate
{

    IPageCommunity community;
    IPageBank public bank;
    IPageToken public token;

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _treasury Address of our treasury
     * @param _admin Address of admin
     */
    function initialize(address _admin, address _token, address _community, address _bank)
        public
        initializer
    {
        __Ownable_init();

        require(_admin != address(0), "PageVote: wrong admin address");
        require(_token != address(0), "PageVote: wrong token address");
        require(_community != address(0), "PageVote: wrong community address");
        require(_bank != address(0), "PageCommunity: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

        token = IPageToken(_token);
        community = IPageCommunity(_community);
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
     * @dev Accepts ether to the balance of the contract
     * Required for testing
     *
     */
    receive() external payable {
        // React to receiving ether
        // Uncomment for production
        //revert("PageBank: asset transfer prohibited");
    }
}
