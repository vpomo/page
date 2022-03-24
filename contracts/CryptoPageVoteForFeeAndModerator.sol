// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageCommunity.sol";
import "./interfaces/ICryptoPageToken.sol";

contract PageVoteForFeeAndModerator is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{

    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");
    uint128 public MIN_DURATION = 3 days;

    IPageCommunity community;
    IPageBank public bank;
    IPageToken public token;

    struct Vote {
        string description;
        address creator;
        uint128 execMethodNumber;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint256[4] newValues;
        address user;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    //communityId -> Vote[]
    mapping(uint256 => Vote[]) private votes;

    event SetMinDuration(uint256 oldValue, uint256 newValue);
    event PutVote(address indexed sender, bool isYes, uint256 weight);
    event CreateVote(address indexed sender, uint128 duration, uint128 methodNumber, uint256[4] values);
    event ExecuteVote(address sender);

    function initialize(address _admin, address _token, address _community, address _bank) public initializer {
        __Ownable_init();
        require(_admin != address(0), "PageVote: wrong admin address");
        require(_token != address(0), "PageCommunity: wrong token address");
        require(_community != address(0), "PageVote: wrong community address");
        require(_bank != address(0), "PageCommunity: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);

        token = IPageToken(_token);
        community = IPageCommunity(_community);
        bank = IPageBank(_bank);
    }

    function version() public view returns (string memory) {
        return "1";
    }

    function createVote(
        uint256 communityId,
        string description,
        uint128 duration,
        uint128 methodNumber,
        uint256[4] memory values,
        address user
    ) external {
        require(duration >= MIN_DURATION, "PageVote: wrong duration");
        address sender = _msgSender();
        require(community.isCommunityModerator(communityId, sender) || community.isCommunityCreator(communityId, sender), "PageVote: access denied");
        require(0 < methodNumber && methodNumber < 5, "PageVote: wrong methodNumber");

        Vote storage vote;
        vote.description = description;
        vote.creator = sender;
        vote.execMethodNumber = methodNumber;
        vote.newValues = values;
        vote.finishTime = block.timestamp + duration;
        vote.active = true;
        if (methodNumber == 3 || methodNumber == 4) {
            require(user != address(0), "PageVote: wrong moderator address");
            vote.user = user;
        }

        votes[communityId].push(vote);
        emit CreateVote(sender, duration, methodNumber, values);
    }

    function setMinDuration(uint256 minDuration) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(minDuration != MIN_DURATION, "PageVote: wrong value");
        emit SetMinDuration(MIN_DURATION, minDuration);
        MIN_DURATION = minDuration;
    }

    function putVote(uint256 communityId, uint256 index, bool isYes) external {
        require(votes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        Vote storage vote = votes[communityId][index];

        require(community.isCommunityUser(communityId, sender), "PageVote: access denied");
        require(!vote.voteUsers.contains(sender), "PageVote: the user has already voted");
        require(vote.active, "PageVote: vote not active");

        uint256 weight = bank.balanceOf(sender) + token.balanceOf(sender);

        if (isYes) {
            vote.yesCount += weight;
        } else {
            vote.noCount += weight;
        }
        vote.voteUsers.add(sender);
        emit PutVote(sender, isYes, weight);
    }

    function executeVote(uint256 communityId, uint256 index) external {
        require(votes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        Vote storage vote = votes[communityId][index];

        require(community.isCommunityUser(communityId, sender), "PageVote: access denied");
        require(vote.voteUsers.contains(sender), "PageVote: the user did not vote");
        require(vote.active, "PageVote: vote not active");
        require(vote.finishTime < block.timestamp, "PageVote: wrong time");

        executeScript(communityId, index);
        vote.active = false;

        emit ExecuteVote(sender);
    }

    function readVote(uint256 communityId, uint256 index) external view returns(
        string description,
        address creator,
        uint128 execMethodNumber,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint256[4] newValues,
        address user,
        address[] voteUsers,
        bool active
    ) {
        require(votes[communityId].length > index, "PageVote: wrong index");

        Vote memory vote = votes[communityId][index];

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

    function executeScript(uint256 communityId, uint256 index) private {
        Vote memory vote = votes[communityId][index];
        uint256 values = vote.newValues;
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
    }
}
