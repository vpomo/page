// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";


/// @title The contract for manage community
/// @author Crypto.Page Team
/// @notice
/// @dev 
contract PageCommunity is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    uint256 public MAX_MODERATORS = 40;

    uint256 private WRONG_MODERATOR_NUMBER = 1000;

    uint256 public communityCount;

    struct Community {
        string name;
        address creator;
        EnumerableSetUpgradeable.AddressSet moderators;
        uint256 usersCount;
        bool active;
    }

    mapping(uint256 => Community) private community;
    mapping(uint256 => mapping(address => bool)) private communityUsers;

    event AddedCommunity(address indexed creator, uint256 number, string name);

    event AddedModerator(address indexed admin, uint256 number, address moderator);
    event RemovedModerator(address indexed admin, uint256 number, address moderator);

    event JoinUser(uint256 communityNumber, address user);
    event QuitUser(uint256 communityNumber, address user);

    modifier validNumber(uint256 number) {
        require(number <= communityCount, "PageCommunity: Wrong index");
        _;
    }

    function addCommunity(string memory desc) public {
        communityCount++;
        Community storage newCommunity = community[communityCount];
        newCommunity.creator = _msgSender();
        newCommunity.active = true;
        newCommunity.name = desc;

        emit AddedCommunity(_msgSender(), communityCount, desc);
    }

    function getCommunity(uint256 communityNumber) public validNumber(communityNumber) view returns(Community memory) {
        return community[communityNumber];
    }

    function addModerator(uint256 communityNumber, address moderator) public validNumber(communityNumber) {
        Community storage currentCommunity = community[communityNumber];
        require(moderator != address(0), "PageCommunity: Wrong moderator");
        require(currentCommunity.moderators.length < MAX_MODERATORS, "PageCommunity: The limit on the number of moderators");

        currentCommunity.moderators.add(moderator);
        emit AddedModerator(_msgSender(), communityNumber, moderator);
    }

    function removeModerator(uint256 communityNumber, address moderator) public validNumber(communityNumber) {
        Community storage currentCommunity = community[communityNumber];
        require(_msgSender() == currentCommunity.creator, "PageCommunity: Wrong creator");

        currentCommunity.moderators.remove(moderator);
        emit RemovedModerator(_msgSender(), communityNumber, moderator);
    }

    function join(uint256 communityNumber) public validNumber(communityNumber) {
        communityUsers[communityNumber][_msgSender()] = true;
        community[communityNumber].usersCount++;
        emit JoinUser(communityNumber, _msgSender());
    }

    function quit(uint256 communityNumber) public validNumber(communityNumber) {
        communityUsers[communityNumber][_msgSender()] = false;
        community[communityNumber].usersCount--;
        emit QuitUser(communityNumber, _msgSender());
    }

    function isExistModerator(uint256 communityNumber, address moderator) public view validNumber(communityNumber)
        returns(bool)
    {
        Community memory currentCommunity = community[communityNumber];
        return currentCommunity.moderators.contains(moderator);
    }
}
