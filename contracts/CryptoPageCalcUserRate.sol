// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageCalcUserRate.sol";
import "./interfaces/ICryptoPageUserRateToken.sol";
import "./interfaces/ICryptoPageCommunity.sol";

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

    IPageUserRateToken public userRateToken;
    IPageCommunity public community;

    enum UserRatesType {
        RESERVE, HUNDRED_UP, THOUSAND_UP, HUNDRED_DOWN, THOUSAND_DOWN,
        TEN_MESSAGES, HUNDRED_MESSAGES, THOUSAND_MESSAGES,
        ONE_LEVEL, TWO_LEVEL, THREE_LEVEL, FOUR_LEVEL, FIVE_LEVEL
    }

    enum ActivityType { POST, MESSAGE, UP, DOWN }

    struct RateCount {
        uint64 postCount;
        uint64 messageCount;
        uint64 upCount;
        uint64 downCount;
    }

    mapping(uint256 => mapping(address => RateCount)) activityCounter;

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _admin Address of admin
     * @param _community Address of community
     * @param _bank Address of bank
     */
    function initialize(address _admin, address _community, address _userRateToken)
        public
        initializer
    {
        __Ownable_init();

        require(_admin != address(0), "PageVote: wrong admin address");
        require(_community != address(0), "PageVote: wrong community address");
        require(_userRateToken != address(0), "PageCommunity: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        community = IPageCommunity(_community);
        userRateToken = IPageUserRateToken(_userRateToken);
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

    /**
     * @dev .
     *
     * @param communityId ID of community
     * @param user
     * @param activityType
     */
    function addActivity(uint256 communityId, address user, ActivityType activityType) external override {
        RateCount storage counter = activityCounter[communityId][user];
        if (activityType == ActivityType.POST) {
            counter.postCount++;
        }
        if (activityType == ActivityType.MESSAGE) {
            counter.messageCount++;
        }
        if (activityType == ActivityType.UP) {
            counter.upCount++;
        }
        if (activityType == ActivityType.DOWN) {
            counter.downCount++;
        }
    }

    function checkActivity(uint256 communityId, address user) public {
        RateCount storage counter = activityCounter[communityId][user];
        if (counter.postCount > 0) {
            uint256 postCount = counter.postCount;

        }


    }

}
