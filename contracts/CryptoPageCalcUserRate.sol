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

    uint256 public constant TOKEN_ID_MULTIPLYING_FACTOR = 100;
    bytes public constant FOR_RATE_TOKEN_DATA = "";

    enum UserRatesType {
        RESERVE, HUNDRED_UP, THOUSAND_UP, HUNDRED_DOWN, THOUSAND_DOWN,
        TEN_MESSAGE, HUNDRED_MESSAGE, THOUSAND_MESSAGE,
        TEN_POST, HUNDRED_POST, THOUSAND_POST,
        ONE_LEVEL, TWO_LEVEL, THREE_LEVEL, FOUR_LEVEL, FIVE_LEVEL
    }

    enum ActivityType { POST, MESSAGE, UP, DOWN }

    struct RateCount {
        uint64 messageCount;
        uint64 postCount;
        uint64 upCount;
        uint64 downCount;
    }

    struct RedeemedCount {
        uint64[3] messageCount;
        uint64[3] postCount;
        uint64[2] upCount;
        uint64[2] downCount;
    }

    mapping(uint256 => mapping(address => RateCount)) activityCounter;
    mapping(uint256 => mapping(address => RateCount)) redeemedCounter;

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
        uint256 tokenId = communityId * TOKEN_ID_MULTIPLYING_FACTOR;

        checkMessages(tokenId, communityId, user);
        checkPosts(tokenId, communityId, user);
        checkUps(tokenId, communityId, user);
        checkDowns(tokenId, communityId, user);
    }

    function checkMessages(uint256 communityId, address user) private {
        uint256 realMessageCount = activityCounter[communityId][user].messageCount;

        checkMessagesByIndex(communityId, user, realMessageCount, 0);
        checkMessagesByIndex(communityId, user, realMessageCount, 1);
        checkMessagesByIndex(communityId, user, realMessageCount, 2);
    }

    function checkPosts(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realPostCount = activityCounter[communityId][user].postCount;

        checkPostsByIndex(tokenId, user, realPostCount, 0);
        checkPostsByIndex(tokenId, user, realPostCount, 1);
        checkPostsByIndex(tokenId, user, realPostCount, 2);
    }

    function checkUps(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realUpCount = activityCounter[communityId][user].upCount;

        checkUpsByIndex(tokenId, user, realUpCount, 0);
        checkUpsByIndex(tokenId, user, realUpCount, 1);
    }

    function checkDowns(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realDownCount = activityCounter[communityId][user].downCount;

        checkDownsByIndex(tokenId, user, realDownCount, 0);
        checkDownsByIndex(tokenId, user, realDownCount, 1);
    }

    function checkMessagesByIndex(uint256 tokenId, address user, uint256 realMessageCount, uint256 index) private {
        RateCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realMessageCount / (10 * 10**index);
        uint256 mintNumber = number - redeemCounter.messageCount[index];
        if (mintNumber > 0) {
            redeemCounter.messageCount[index] += mintNumber;
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.TEN_MESSAGE + index), mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    function checkPostsByIndex(uint256 tokenId, address user, uint256 realPostCount, uint256 index) private {
        RateCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realPostCount / (10 * 10**index);
        uint256 mintNumber = number - redeemCounter.postCount[index];
        if (mintNumber > 0) {
            redeemCounter.postCount[index] += mintNumber;
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.TEN_POST + index), mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    function checkUpsByIndex(uint256 tokenId, address user, uint256 realUpCount, uint256 index) private {
        RateCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realUpCount / (10 * 10**(index+1));
        uint256 mintNumber = number - redeemCounter.upCount[index];
        if (mintNumber > 0) {
            redeemCounter.upCount[index] += mintNumber;
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.HUNDRED_UP + index), mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    function checkDownsByIndex(uint256 tokenId, address user, uint256 realDownCount, uint256 index) private {
        RateCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realDownCount / (10 * 10**(index+1));
        uint256 mintNumber = number - redeemCounter.downCount[index];
        if (mintNumber > 0) {
            redeemCounter.downCount[index] += mintNumber;
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.HUNDRED_DOWN + index), mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }
}
