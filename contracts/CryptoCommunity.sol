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

    IPageNFT public nft;

    uint256 public MAX_MODERATORS = 40;
    uint256 private WRONG_MODERATOR_NUMBER = 1000;

    uint256 public FOR_MINT_GAS_AMOUNT = 2800;
    uint256 public FOR_BURN_GAS_AMOUNT = 2800;

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

    mapping(uint256 => uint256) private pricesByPostId;
    mapping(uint256 => uint256[]) private postsIdsByCommunityId;

    event AddedCommunity(address indexed creator, uint256 number, string name);

    event AddedModerator(address indexed admin, uint256 number, address moderator);
    event RemovedModerator(address indexed admin, uint256 number, address moderator);

    event JoinUser(uint256 indexed communityId, address user);
    event QuitUser(uint256 indexed communityId, address user);

    event WritePost(uint256 indexed communityId, uint256 postId, address creator);

    modifier validId(uint256 id) {
        validateCommunity(id);
        _;
    }

    modifier onlyModerator(uint256 number) {
        require(isExistModerator(number, _msgSender()), "PageCommunity: wrong moderator");
        _;
    }

    modifier onlyCommunityUser(uint256 number) {
        validateCommunity(number);
        require(communityUsers[number][_msgSender()], "PageCommunity: wrong user");
        _;
    }

    function initialize(address _nft) public initializer {
        nft = IPageNFT(_nft);
    }

    function addCommunity(string memory desc) public {
        communityCount++;
        Community storage newCommunity = community[communityCount];
        newCommunity.creator = _msgSender();
        newCommunity.active = true;
        newCommunity.name = desc;

        emit AddedCommunity(_msgSender(), communityCount, desc);
    }

    function getCommunity(uint256 communityId) public validId(communityId) view returns(Community memory) {
        return community[communityId];
    }

    function addModerator(uint256 communityId, address moderator) public validId(communityId) {
        Community storage currentCommunity = community[communityId];
        require(moderator != address(0), "PageCommunity: Wrong moderator");
        require(currentCommunity.moderators.length < MAX_MODERATORS, "PageCommunity: The limit on the number of moderators");

        currentCommunity.moderators.add(moderator);
        emit AddedModerator(_msgSender(), communityId, moderator);
    }

    function removeModerator(uint256 communityId, address moderator) public validId(communityId) {
        Community storage currentCommunity = community[communityId];
        require(_msgSender() == currentCommunity.creator, "PageCommunity: Wrong creator");

        currentCommunity.moderators.remove(moderator);
        emit RemovedModerator(_msgSender(), communityId, moderator);
    }

    function join(uint256 communityId) external validId(communityId) {
        communityUsers[communityId][_msgSender()] = true;
        community[communityId].usersCount++;
        emit JoinUser(communityId, _msgSender());
    }

    function quit(uint256 communityId) external validId(communityId) {
        communityUsers[communityId][_msgSender()] = false;
        community[communityId].usersCount--;
        emit QuitUser(communityId, _msgSender());
    }

    function isExistModerator(uint256 communityId, address moderator) public view validId(communityId)
        returns(bool)
    {
        Community memory currentCommunity = community[communityId];
        return currentCommunity.moderators.contains(moderator);
    }

    function writePost(
        uint256 communityId,
        string memory ipfsHash,
        address owner
    ) external validId(communityId) onlyCommunityUser(communityId) returns() {
        uint256 gasBefore = gasleft();
        require(owner != address(0), "PageCommunity: Wrong owner");
        uint256 postId = nft.mint(owner);
        postsIdsByCommunityId.push(postId);
        emit WritePost(communityId, postId, _msgSender());

        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.mintTokenForNewPost(_msgSender(), owner, gas + FOR_MINT_GAS_AMOUNT);

        pricesByPostId[postId] = price;
    }

    function getPostPrice(uint256 postId) public view returns (uint256) {
        return pricesByPostId[postId];
    }

    function getPostsIdsByCommunityId(uint256 communityId) public view override returns (uint256[] memory) {
        return postsIdsByCommunityId[communityId];
    }

    function validateCommunity(uint256 communityId) private {
        require(number <= communityCount, "PageCommunity: wrong community number");
    }
}
