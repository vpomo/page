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
        EnumerableSetUpgradeable.UintSet postIds;
        EnumerableSetUpgradeable.AddressSet users;
        uint256 usersCount;
        bool active;
    }

    struct Post {
        string ipfsHash;
        address creator;
        address owner;
        uint64 upCount;
        uint64 downCount;
        uint128 price;
        uint256 count;
        bool active;
    }

    struct Comment {
        string ipfsHash;
        address creator;
        address owner;
        uint64 upCount;
        uint64 downCount;
        uint128 price;
        bool active;
    }

    mapping(uint256 => Community) private community;

    //nftId -> Post
    mapping(uint256 => Post) private post;
    //nftId -> commentId -> Comment
    mapping(uint256 => mapping(uint256 => Comment)) private comment;


    event AddedCommunity(address indexed creator, uint256 number, string name);

    event AddedModerator(address indexed admin, uint256 number, address moderator);
    event RemovedModerator(address indexed admin, uint256 number, address moderator);

    event JoinUser(uint256 indexed communityId, address user);
    event QuitUser(uint256 indexed communityId, address user);

    event WritePost(uint256 indexed communityId, uint256 postId, address creator, address owner);
    event WriteComment(uint256 indexed communityId, uint256 postId, uint256 commentId, address creator, address owner);

    modifier validId(uint256 id) {
        validateCommunity(id);
        _;
    }

    modifier onlyModerator(uint256 number) {
        require(isExistModerator(number, _msgSender()), "PageCommunity: wrong moderator");
        _;
    }

    modifier onlyCommunityUser(uint256 id) {
        validateCommunity(id);
        require(community[id].users.contains(_msgSender()), "PageCommunity: wrong user");
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
        community[id].users.add(_msgSender());
        community[communityId].usersCount++;
        emit JoinUser(communityId, _msgSender());
    }

    function quit(uint256 communityId) external validId(communityId) {
        community[id].users.remove(_msgSender());
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
        require(community[id].users.contains(_msgSender()), "PageCommunity: wrong user");
        require(community[id].users.contains(owner), "PageCommunity: wrong user");

        uint256 postId = nft.mint(owner);
        createPost(postId, owner);

        community[communityId].postIds.add(postId);
        emit WritePost(communityId, postId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.mintTokenForNewPost(_msgSender(), owner, gas + FOR_MINT_GAS_AMOUNT);
        setPostPrice(postId, price);
    }

    function writeComment(
        uint256 communityId,
        uint256 postId,
        string memory ipfsHash,
        address owner
    ) external validId(communityId) onlyCommunityUser(communityId) returns() {
        uint256 gasBefore = gasleft();
        require(community[id].users.contains(_msgSender()), "PageCommunity: wrong user");
        require(community[id].users.contains(owner), "PageCommunity: wrong user");
        incCommentCount(postId);
        createComment(postId, ipfsHash, owner);
        uint256 commentId = getCurrentCommentCount(postId);

        emit WriteComment(communityId, postId, commentId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.mintTokenForNewPost(_msgSender(), owner, gas + FOR_MINT_GAS_AMOUNT);
        setCommentPrice(postId, commentId, price);
    }

    function readPost(uint256 postId) external view returns(
        string ipfsHash,
        address creator,
        address owner,
        uint64 upCount,
        uint64 downCount,
        uint128 price,
        uint256 count,
        bool active
    ) {
        Post memory readed = post[postId];
        ipfsHash = readed.ipfsHash;
        creator = readed.creator;
        owner = readed.owner;
        upCount = readed.upCount;
        downCount = readed.downCount;
        price = readed.price;
        count = readed.count;
        active = readed.active;
    }

    function getPostPrice(uint256 postId) public view returns (uint256) {
        return post[postId].price;
    }

    function getPostsIdsByCommunityId(uint256 communityId) public view override returns (uint256[] memory) {
        return community[communityId].postIds.values();
    }

    function validateCommunity(uint256 communityId) private {
        require(number <= communityCount, "PageCommunity: wrong community number");
    }

    function createPost(uint256 postId, address owner, string memory ipfsHash) private {
        Post storage newPost = post[postId];
        newPost.ipfsHash = ipfsHash;
        newPost.creator = _msgSender();
        newPost.owner = owner;
        newPost.active = true;
    }

    function setPostPrice(uint256 postId, uint256 price) private {
        Post storage curPost = post[postId];
        curPost.price = price;
    }

    function incCommentCount(uint256 postId) private {
        Post storage curPost = post[postId];
        curPost.count++;
    }

    function getCurrentCommentCount(uint256 postId) public returns(uint256) {
        Post memory curPost = post[postId];
        return curPost.count;
    }

    function createComment(uint256 postId, string memory ipfsHash, address owner) private {
        uint256 commentId = post[postId].count;
        Comment storage newComment = comment[postId][commentId];
        newComment.ipfsHash = ipfsHash;
        newComment.creator = _msgSender();
        newComment.owner = owner;
        newComment.active = true;
    }

    function setCommentPrice(uint256 postId, uint256 commentId, uint256 price) private {
        Comment storage curComment = comment[postId][commentId];
        curComment.price = price;
    }
}
