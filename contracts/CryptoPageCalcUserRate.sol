// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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
AccessControlUpgradeable,
IPageCalcUserRate
{

    IPageUserRateToken public userRateToken;

    bytes32 public constant BANK_ROLE = keccak256("BANK_ROLE");

    uint256 public constant TOKEN_ID_MULTIPLYING_FACTOR = 100;
    bytes public FOR_RATE_TOKEN_DATA = "";

    //for RedeemedCount
    uint256[10] public interestAdjustment = [5, 20, 30, 40, 50, 60, 20, 40, 20, 40];

    enum UserRatesType {
        RESERVE, HUNDRED_UP, THOUSAND_UP, HUNDRED_DOWN, THOUSAND_DOWN,
        TEN_MESSAGE, HUNDRED_MESSAGE, THOUSAND_MESSAGE,
        TEN_POST, HUNDRED_POST, THOUSAND_POST,
        ONE_LEVEL, TWO_LEVEL, THREE_LEVEL, FOUR_LEVEL, FIVE_LEVEL
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

    function checkActivity(uint256 communityId, address user, ActivityType activityType) external override onlyRole(BANK_ROLE)
        returns(int256 resultPercent)
    {
        addActivity(communityId, user, activityType);
        uint256 baseTokenId = communityId * TOKEN_ID_MULTIPLYING_FACTOR;

        checkMessages(baseTokenId, communityId, user);
        checkPosts(baseTokenId, communityId, user);
        checkUps(baseTokenId, communityId, user);
        checkDowns(baseTokenId, communityId, user);

        return calcPercent(user, baseTokenId);
    }

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

    function checkMessages(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realMessageCount = activityCounter[communityId][user].messageCount;

        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 0);
        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 1);
        checkMessagesByIndex(tokenId, communityId, user, realMessageCount, 2);
    }

    function checkPosts(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realPostCount = activityCounter[communityId][user].postCount;

        checkPostsByIndex(tokenId, communityId, user, realPostCount, 0);
        checkPostsByIndex(tokenId, communityId, user, realPostCount, 1);
        checkPostsByIndex(tokenId, communityId, user, realPostCount, 2);
    }

    function checkUps(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realUpCount = activityCounter[communityId][user].upCount;

        checkUpsByIndex(tokenId, communityId, user, realUpCount, 0);
        checkUpsByIndex(tokenId, communityId, user, realUpCount, 1);
    }

    function checkDowns(uint256 tokenId, uint256 communityId, address user) private {
        uint256 realDownCount = activityCounter[communityId][user].downCount;

        checkDownsByIndex(tokenId, communityId, user, realDownCount, 0);
        checkDownsByIndex(tokenId, communityId, user, realDownCount, 1);
    }

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
     * @dev .
     *
     * @param communityId ID of community
     * @param user aaa
     * @param activityType aa
     */
    function addActivity(uint256 communityId, address user, ActivityType activityType) private {
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
}
