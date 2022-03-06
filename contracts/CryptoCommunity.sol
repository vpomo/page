// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";


/// @title The contract for manage community
/// @author Crypto.Page Team
/// @notice
/// @dev 
contract PageCommunity is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{
    uint256 public MAX_MODERATORS = 40;

    uint256 private WRONG_MODERATOR_NUMBER = 1000;

    uint256 public communityCount;

    struct Community {
        string name;
        address creator;
        address[] moderators;
        bool active;
    }

    mapping(uint256 => Community) private community;

    event AddedCommunity(address indexed creator, uint256 number, string name);

    event AddedModerator(address indexed admin, uint256 number, address moderator);
    event RemovedModerator(address indexed admin, uint256 number, address moderator);

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

    function getCommunity(uint256 communityNumber) public validNumber(communityNumber) view returns(Community) {
        return community[communityNumber];
    }

    function addModerator(uint256 communityNumber, address moderator) public validNumber(communityNumber) {
        Community storage currentCommunity = community[communityNumber];
        require(moderator != address(0), "PageCommunity: Wrong moderator");
        require(currentCommunity.moderators.length <= MAX_MODERATORS, "PageCommunity: The limit on the number of moderators");

        currentCommunity.moderators.push(moderator);
        emit AddedModerator(_msgSender(), communityNumber, moderator);
    }

    function removeModerator(uint256 communityNumber, address moderator) public validNumber(communityNumber) {
        Community storage currentCommunity = community[communityNumber];
        uint256 index = findModerator(communityNumber, moderator);

        require(index < WRONG_MODERATOR_NUMBER, "PageCommunity: Wrong moderator");

        for (uint i = index; i<currentCommunity.moderators.length-1; i++){
            currentCommunity.moderators[i] = currentCommunity.moderators[i+1];
        }
        currentCommunity.moderators.pop();
        emit RemovedModerator(_msgSender(), communityNumber, moderator);
    }

    function findModerator(uint256 communityNumber, address moderator) public validNumber(communityNumber) returns(uint256 index)
    {
        index = WRONG_MODERATOR_NUMBER;
        Community memory currentCommunity = community[communityNumber];
        for (uint j = 0; j<currentCommunity.moderators.length; j++) {
            if (currentCommunity.moderators[j] == moderator) {
                index = j;
                break;
            }
        }
    }
}
