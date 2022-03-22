// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageCommunity.sol";

contract PageVote is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{

    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");
    uint256 public MIN_DURATION = 3 days;

    IPageCommunity community;

    struct Vote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    //communityId -> Vote[]
    mapping(uint256 => Vote[]) private votes;

    function initialize(address _admin, address _community) public initializer {
        __Ownable_init();
        require(_admin != address(0), "PageVote: wrong admin address");
        require(_community != address(0), "PageVote: wrong community address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);

        community = IPageCommunity(_community);
    }

    function createVote(
        uint256 communityId,
        string description,
        uint128 duration
    ) external {
        // TODO check creator, duration

        Vote memory vote;
        vote.description = description;
        vote.creator = _msgSender();
        vote.finishTime = block.timestamp + duration;
        vote.active = true;

        votes[communityId].push(vote);
    }

    //TODO set min_duration

    function readVote(uint256 communityId, uint256 index) external view returns(
        string description,
        address creator,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        EnumerableSetUpgradeable.AddressSet voteUsers,
        bool active
    ) {
        require(votes[communityId].length > index, "PageVote: wrong index");

        Vote memory vote = votes[communityId][index];

        description = vote.description;
        creator = vote.creator;
        finishTime = vote.finishTime;
        yesCount = vote.yesCount;
        noCount = vote.noCount;
        voteUsers = vote.voteUsers.values();
        active = vote.active;
    }

}
