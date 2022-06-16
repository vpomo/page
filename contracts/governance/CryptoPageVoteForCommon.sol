// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";

import {DataTypes} from '../libraries/DataTypes.sol';
import "../interfaces/ICryptoPageBank.sol";
import "../interfaces/ICryptoPageCommunity.sol";
import "../interfaces/ICryptoPageToken.sol";
import "../interfaces/ICryptoPageVoteForCommon.sol";

contract PageVoteForCommon is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageVoteForCommon
{

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");
    uint128 public MIN_DURATION = 1 days;

    IPageCommunity community;
    IPageBank public bank;
    IPageToken public token;

    //communityId -> Vote[]
    mapping(uint256 => DataTypes.AddressUintsVote[]) private votes;

    event SetMinDuration(uint256 oldValue, uint256 newValue);
    event PutVote(address indexed sender, uint256 communityId, uint256 index, bool isYes, uint256 weight);
    event CreateVote(address indexed sender, uint128 duration, uint128 methodNumber, uint64[4] values, address user);
    event ExecuteVote(address sender, uint256 communityId, uint256 index);

    modifier validMethodId(uint256 id) {
        require(0 < id && id < 7, "PageVote: wrong methodNumber");
        _;
    }

    function initialize(address _admin, address _token, address _community, address _bank) public initializer {
        __Ownable_init();
        require(_admin != address(0), "PageVote: wrong admin address");
        require(_token != address(0), "PageVote: wrong token address");
        require(_community != address(0), "PageVote: wrong community address");
        require(_bank != address(0), "PageCommunity: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);

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
        //revert("PageVote: asset transfer prohibited");
    }

    /**
     * @dev Creates a new community vote proposal.
     *
     * @param communityId ID of community
     * @param description Brief text description for the proposal
     * @param duration Voting duration in seconds
     * @param methodNumber Method number for "executeScript()" function
     * @param values Values for methods 1 and 2
     * @param user Value for methods 3 and 4
     */
    function createVote(
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint128 methodNumber,
        uint64[4] memory values,
        address user
    ) external override validMethodId(methodNumber) {
        require(duration >= MIN_DURATION, "PageVote: wrong duration");
        address sender = _msgSender();
        require(community.isCommunityModerator(communityId, sender) || community.isCommunityCreator(communityId, sender), "PageVote: access denied");

        uint256 len = readVotesCount(communityId);
        votes[communityId].push();

        DataTypes.AddressUintsVote storage vote = votes[communityId][len];
        vote.description = description;
        vote.creator = sender;
        vote.execMethodNumber = methodNumber;
        vote.newValues = values;
        vote.finishTime = uint128(block.timestamp) + duration;
        vote.active = true;
        if (methodNumber == 3 || methodNumber == 4) {
            require(user != address(0), "PageVote: wrong moderator address");
            vote.user = user;
        }

        emit CreateVote(sender, duration, methodNumber, values, user);
    }

    /**
     * @dev Changes value for MIN_DURATION variable.
     * This variable contains the value for the minimum voting period.
     *
     * @param minDuration New value for MIN_DURATION variable
     */
    function setMinDuration(uint128 minDuration) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(minDuration != MIN_DURATION, "PageVote: wrong value");
        emit SetMinDuration(MIN_DURATION, minDuration);
        MIN_DURATION = minDuration;
    }

    /**
     * @dev Here the user votes either for the implementation of the proposal or against.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     * @param isYes For the implementation of the proposal or against the implementation
     */
    function putVote(uint256 communityId, uint256 index, bool isYes) external {
        require(votes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        DataTypes.AddressUintsVote storage vote = votes[communityId][index];

        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");
        require(!vote.voteUsers.contains(sender), "PageVote: the user has already voted");
        require(vote.active, "PageVote: vote not active");

        uint256 weight = bank.balanceOf(sender) + token.balanceOf(sender);

        if (isYes) {
            vote.yesCount += uint128(weight);
        } else {
            vote.noCount += uint128(weight);
        }
        vote.voteUsers.add(sender);
        emit PutVote(sender, communityId, index, isYes, weight);
    }

    /**
     * @dev Starts the execution of a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeVote(uint256 communityId, uint256 index) external override {
        require(votes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        DataTypes.AddressUintsVote storage vote = votes[communityId][index];

        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");
        require(vote.voteUsers.contains(sender), "PageVote: the user did not vote");
        require(vote.active, "PageVote: vote not active");
        require(vote.finishTime < block.timestamp, "PageVote: wrong time");
        require(vote.yesCount > vote.noCount, "PageVote: wrong yes count");
        if (vote.yesCount > vote.noCount) {
            executeScript(communityId, index);
        }

        vote.active = false;

        emit ExecuteVote(sender, communityId, index);
    }

    /**
     * @dev Reading information about a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function readVote(uint256 communityId, uint256 index) external override view returns(
        string memory description,
        address creator,
        uint128 execMethodNumber,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint64[4] memory newValues,
        address user,
        address[] memory voteUsers,
        bool active
    ) {
        require(votes[communityId].length > index, "PageVote: wrong index");

        DataTypes.AddressUintsVote storage vote = votes[communityId][index];

        description = vote.description;
        creator = vote.creator;
        execMethodNumber = vote.execMethodNumber;
        finishTime = vote.finishTime;
        yesCount = vote.yesCount;
        noCount = vote.noCount;
        newValues = vote.newValues;
        user = vote.user;
        voteUsers = vote.voteUsers.values();
        active = vote.active;
    }

    /**
     * @dev Reading the amount of votes for the community.
     *
     * @param communityId ID of community
     */
    function readVotesCount(uint256 communityId) public override view returns(uint256 count) {
        return votes[communityId].length;
    }

    /**
     * @dev Starts the execution of a method for the community.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeScript(uint256 communityId, uint256 index) private {
        DataTypes.AddressUintsVote storage vote = votes[communityId][index];
        uint64[4] storage values = vote.newValues;
        if (vote.execMethodNumber == 1) {
            bank.updatePostFee(communityId, values[0], values[1], values[2], values[3]);
        }
        if (vote.execMethodNumber == 2) {
            bank.updateCommentFee(communityId, values[0], values[1], values[2], values[3]);
        }
        if (vote.execMethodNumber == 3) {
            community.addModerator(communityId, vote.user);
        }
        if (vote.execMethodNumber == 4) {
            community.removeModerator(communityId, vote.user);
        }
        if (vote.execMethodNumber == 5) {
            community.setPostOwner(communityId);
        }
        if (vote.execMethodNumber == 6) {
            community.changeCommunityActive(communityId);
        }
    }
}