// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageCalcUserRate.sol";
import "./interfaces/ICryptoPageUserRateToken.sol";
import "./interfaces/ICryptoPageCommunity.sol";

import {DataTypes} from './libraries/DataTypes.sol';


/// @title The contract calculates rates of users
/// @author Crypto.Page Team
/// @notice
/// @dev
contract PageCalcUserRate is
Initializable,
AccessControlUpgradeable,
IPageCalcUserRate
{

    IPageUserRateToken public userRateToken;

    bytes32 public constant BANK_ROLE = keccak256("BANK_ROLE");
    bytes32 public constant DEAL_ROLE = keccak256("DEAL_ROLE");

    uint256 public constant TOKEN_ID_MULTIPLYING_FACTOR = 100;
    bytes public FOR_RATE_TOKEN_DATA = "";

    //for RedeemedCount
    uint256[10] public interestAdjustment = [1, 10, 30, 40, 50, 60, 20, 40, 20, 40];

    enum UserRatesType {
        RESERVE, HUNDRED_UP, THOUSAND_UP, HUNDRED_DOWN, THOUSAND_DOWN,
        TEN_MESSAGE, HUNDRED_MESSAGE, THOUSAND_MESSAGE,
        TEN_POST, HUNDRED_POST, THOUSAND_POST,
        DEAL_GUARANTOR, DEAL_SELLER, DEAL_BUYER
    }

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

    mapping(uint256 => mapping(address => RateCount)) private activityCounter;
    mapping(uint256 => mapping(address => RedeemedCount)) private redeemedCounter;

    event SetInterestAdjustment(uint256[10] oldValue, uint256[10] newValue);
    event AddedDealActivity(address user, DataTypes.ActivityType activityType);

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _admin Address of admin
     * @param _userRateToken Address of bank
     */
    function initialize(address _admin, address _userRateToken) public initializer {
        require(_admin != address(0), "PageCalcUserRate: wrong admin address");
        require(_userRateToken != address(0), "PageCalcUserRate: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(BANK_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(DEAL_ROLE, DEFAULT_ADMIN_ROLE);

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
     * @dev The main function for users who write messages.
     * Keeps records of user activities.
     *
     * @param communityId ID of community
     * @param user User wallet address
     * @param activityType Activity type, taken from enum
     */
    function checkCommunityActivity(
        uint256 communityId,
        address user,
        DataTypes.ActivityType activityType
    ) external override onlyRole(BANK_ROLE) returns(int256 resultPercent)
    {
        addActivity(communityId, user, activityType);
        uint256 baseTokenId = communityId * TOKEN_ID_MULTIPLYING_FACTOR;

        checkMessages(baseTokenId, communityId, user);
        checkPosts(baseTokenId, communityId, user);
        checkUps(baseTokenId, communityId, user);
        checkDowns(baseTokenId, communityId, user);

        return calcPercent(user, baseTokenId);
    }

    /**
     * @dev The function for users making deals.
     * Keeps records of user activities.
     *
     * @param user User wallet address
     * @param activityType Activity type, taken from enum
     */
    function addDealActivity(address user, DataTypes.ActivityType activityType) external override onlyRole(DEAL_ROLE) {
        uint256 tokenId = 0;
        if (activityType == DataTypes.ActivityType.DEAL_GUARANTOR) {
            tokenId = uint256(UserRatesType.DEAL_GUARANTOR);
        }
        if (activityType == DataTypes.ActivityType.DEAL_SELLER) {
            tokenId = uint256(UserRatesType.DEAL_SELLER);
        }
        if (activityType == DataTypes.ActivityType.DEAL_BUYER) {
            tokenId = uint256(UserRatesType.DEAL_BUYER);
        }

        userRateToken.mint(user, tokenId, 1, FOR_RATE_TOKEN_DATA);
        emit AddedDealActivity(user, activityType);
    }

    /**
     * @dev Calculates the percentage for accruing tokens when creating a post or message.
     *
     * @param user User wallet address
     * @param baseTokenId Token ID for rating tokens
     */
    function calcPercent(address user, uint256 baseTokenId) public view returns(int256 resultPercent) {
        resultPercent = 0;
        uint256[10] memory weight = interestAdjustment;
        uint256[] memory messageAmount = new uint256[](3);
        uint256[] memory postAmount = new uint256[](3);
        uint256[] memory upAmount = new uint256[](2);
        uint256[] memory downAmount = new uint256[](2);

        messageAmount[0] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_MESSAGE) + 0);
        messageAmount[1] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_MESSAGE) + 1);
        messageAmount[2] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_MESSAGE) + 2);

        postAmount[0] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_POST) + 0);
        postAmount[1] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_POST) + 1);
        postAmount[2] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.TEN_POST) + 2);

        upAmount[0] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.HUNDRED_UP) + 0);
        upAmount[1] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.HUNDRED_UP) + 1);

        downAmount[0] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.HUNDRED_DOWN) + 0);
        downAmount[1] = userRateToken.balanceOf(user, baseTokenId + uint256(UserRatesType.HUNDRED_DOWN) + 1);

        resultPercent += int256(weight[0] * messageAmount[0] + weight[1] * messageAmount[1] + weight[2] * messageAmount[2]);
        resultPercent += int256(weight[3] * postAmount[0] + weight[4] * postAmount[1] + weight[5] * postAmount[2]);
        resultPercent += int256(weight[6] * upAmount[0] + weight[7] * upAmount[1]);
        resultPercent -= int256(weight[8] * downAmount[0] + weight[9] * downAmount[1]);
    }

    /**
     * @dev Shows user activity when creating posts or messages.
     *
     * @param communityId ID of community
     * @param user User wallet address
     */
    function getUserActivity(uint256 communityId, address user) external override view returns(
        uint64 messageCount,
        uint64 postCount,
        uint64 upCount,
        uint64 downCount
    ) {
        RateCount memory counter = activityCounter[communityId][user];

        messageCount = counter.messageCount;
        postCount = counter.postCount;
        upCount = counter.upCount;
        downCount = counter.downCount;
    }

    /**
     * @dev Shows the activity of the user paid for by NFT tokens for rating when creating posts or messages.
     *
     * @param communityId ID of community
     * @param user User wallet address
     */
    function getUserRedeemed(uint256 communityId, address user) external override view returns(
        uint64[3] memory messageCount,
        uint64[3] memory postCount,
        uint64[2] memory upCount,
        uint64[2] memory downCount
    ) {
        RedeemedCount memory counter = redeemedCounter[communityId][user];

        messageCount = counter.messageCount;
        postCount = counter.postCount;
        upCount = counter.upCount;
        downCount = counter.downCount;
    }

    /**
     * @dev Allows you to change the values for interest calculation.
     *
     * @param values Array of new values
     */
    function setInterestAdjustment(uint256[10] calldata values) onlyRole(DEFAULT_ADMIN_ROLE) external override {
        uint256 all;
        for (uint256 i=0; i<10; i++) {
            all += values[i];
        }
        require(all <= 10000, "PageCalcUserRate: wrong values");
        emit SetInterestAdjustment(interestAdjustment, values);
        interestAdjustment = values;
    }


    // *** --- Private area --- ***

    /**
     * @dev Checking and counting user messages.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     */
    function checkMessages(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realMessageCount = activityCounter[communityId][user].messageCount;

        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 0);
        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 1);
        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 2);
    }

    /**
     * @dev Checking and counting user posts.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     */
    function checkPosts(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realPostCount = activityCounter[communityId][user].postCount;

        checkPostsByIndex(tokenId, communityId, user, realPostCount, 0);
        checkPostsByIndex(tokenId, communityId, user, realPostCount, 1);
        checkPostsByIndex(tokenId, communityId, user, realPostCount, 2);
    }

    /**
     * @dev Checking and counting user Upvotes.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     */
    function checkUps(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realUpCount = activityCounter[communityId][user].upCount;

        checkUpsByIndex(tokenId, communityId, user, realUpCount, 0);
        checkUpsByIndex(tokenId, communityId, user, realUpCount, 1);
    }

    /**
     * @dev Checking and counting user Downvotes.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     */
    function checkDowns(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realDownCount = activityCounter[communityId][user].downCount;

        checkDownsByIndex(tokenId, communityId, user, realDownCount, 0);
        checkDownsByIndex(tokenId, communityId, user, realDownCount, 1);
    }

    /**
     * @dev Checking messages for mint new tokens.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     * @param realMessageCount Total user messages
     * @param index Decimal for count
     */
    function checkMessagesByIndex(
        uint256 tokenId,
        uint256 communityId,
        address user,
        uint256 realMessageCount,
        uint256 index
    ) private {
        RedeemedCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realMessageCount / (10 * 10**index);
        uint64 mintNumber = uint64(number) - redeemCounter.messageCount[index];
        if (mintNumber > 0) {
            redeemCounter.messageCount[index] += mintNumber;
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.TEN_MESSAGE) + index, mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    /**
     * @dev Checking posts for mint new tokens.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     * @param realPostCount Total user posts
     * @param index Decimal for count
     */
    function checkPostsByIndex(uint256 tokenId, uint256 communityId, address user, uint256 realPostCount, uint256 index) private {
        RedeemedCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realPostCount / (10 * 10**index);
        uint256 mintNumber = number - redeemCounter.postCount[index];
        if (mintNumber > 0) {
            redeemCounter.postCount[index] += uint64(mintNumber);
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.TEN_POST) + index, mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    /**
     * @dev Checking Upvotes for mint new tokens.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     * @param realUpCount Total user Upvotes
     * @param index Decimal for count
     */
    function checkUpsByIndex(uint256 tokenId, uint256 communityId, address user, uint256 realUpCount, uint256 index) private {
        RedeemedCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realUpCount / (10 * 10**(index+1));
        uint256 mintNumber = number - redeemCounter.upCount[index];
        if (mintNumber > 0) {
            redeemCounter.upCount[index] += uint64(mintNumber);
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.HUNDRED_UP) + index, mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    /**
     * @dev Checking Downvotes for mint new tokens.
     *
     * @param tokenId Token ID for rating tokens
     * @param communityId ID of community
     * @param user User wallet address
     * @param realDownCount Total user Downvotes
     * @param index Decimal for count
     */
    function checkDownsByIndex(uint256 tokenId, uint256 communityId, address user, uint256 realDownCount, uint256 index) private {
        RedeemedCount storage redeemCounter = redeemedCounter[communityId][user];

        uint256 number = realDownCount / (10 * 10**(index+1));
        uint256 mintNumber = number - redeemCounter.downCount[index];
        if (mintNumber > 0) {
            redeemCounter.downCount[index] += uint64(mintNumber);
            userRateToken.mint(
                user, tokenId + uint256(UserRatesType.HUNDRED_DOWN) + index, mintNumber, FOR_RATE_TOKEN_DATA
            );
        }
    }

    /**
     * @dev Adds new user activities to counters when working in communities.
     *
     * @param communityId ID of community
     * @param user User wallet address
     * @param activityType Activity type, taken from enum
     */
    function addActivity(uint256 communityId, address user, DataTypes.ActivityType activityType) private {
        RateCount storage counter = activityCounter[communityId][user];
        if (activityType == DataTypes.ActivityType.POST) {
            counter.postCount++;
        }
        if (activityType == DataTypes.ActivityType.MESSAGE) {
            counter.messageCount++;
        }
        if (activityType == DataTypes.ActivityType.UP) {
            counter.upCount++;
        }
        if (activityType == DataTypes.ActivityType.DOWN) {
            counter.downCount++;
        }
    }
}
