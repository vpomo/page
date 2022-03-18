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

    uint256 public EMPTY_STRING = "";

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
        uint256 commentCount;
        bool isView;
    }

    struct Comment {
        string ipfsHash;
        address creator;
        address owner;
        bool isUp;
        bool isDown;
        uint128 price;
        bool isView;
    }

    mapping(uint256 => Community) private community;

    //postId -> Post
    mapping(uint256 => Post) private post;
    //postId -> communityId
    mapping(uint256 => uint256) private communityIdByPostId;
    //postId -> commentId -> Comment
    mapping(uint256 => mapping(uint256 => Comment)) private comment;


    event AddedCommunity(address indexed creator, uint256 number, string name);

    event AddedModerator(address indexed admin, uint256 number, address moderator);
    event RemovedModerator(address indexed admin, uint256 number, address moderator);

    event JoinUser(uint256 indexed communityId, address user);
    event QuitUser(uint256 indexed communityId, address user);

    event WritePost(uint256 indexed communityId, uint256 postId, address creator, address owner);
    event BurnPost(uint256 indexed communityId, uint256 postId, address creator, address owner);
    event ChangeVisiblePost(uint256 indexed communityId, uint256 postId, bool isVisible);

    event WriteComment(uint256 indexed communityId, uint256 postId, uint256 commentId, address creator, address owner);
    event BurnComment(uint256 indexed communityId, uint256 postId, uint256 commentId, address creator, address owner);
    event ChangeVisibleComment(uint256 indexed communityId, uint256 postId, uint256 commentId, bool isVisible);

    modifier validId(uint256 id) {
        validateCommunity(id);
        _;
    }

    modifier onlyCommunityUser(uint256 id) {
        validateCommunity(id);
        require(community[id].users.contains(_msgSender()), "PageCommunity: wrong user");
        _;
    }

    modifier onlyCommunityActive(uint256 postId) {
        require(isActiveCommunityByPostId(postId), "PageCommunity: wrong active community");
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

    function getCommunity(uint256 communityId) public view validId(communityId) returns(Community memory) {
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

        require(community[communityId].active, "PageCommunity: wrong active community");
        require(community[communityId].users.contains(_msgSender()), "PageCommunity: wrong user");
        require(community[communityId].users.contains(owner), "PageCommunity: wrong user");

        uint256 postId = nft.mint(owner);
        createPost(postId, owner);

        community[communityId].postIds.add(postId);
        communityIdByPostId[postId] = communityId;
        emit WritePost(communityId, postId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.mintTokenForNewPost(_msgSender(), owner, gas);
        setPostPrice(postId, price);
    }

    function readPost(uint256 postId) external view onlyCommunityActive(postId) returns(
        string ipfsHash,
        address creator,
        address owner,
        uint64 upCount,
        uint64 downCount,
        uint128 price,
        uint256 commentCount,
        bool isView
    ) {
        Post memory readed = post[postId];
        ipfsHash = readed.ipfsHash;
        creator = readed.creator;
        owner = readed.owner;
        upCount = readed.upCount;
        downCount = readed.downCount;
        price = readed.price;
        commentCount = readed.commentCount;
        isView = readed.isView;
    }

    function burnPost(
        uint256 postId
    ) external onlyCommunityActive(postId) returns() {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(community[communityId].users.contains(_msgSender()), "PageCommunity: wrong user");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");
        require(post[postId].owner == _msgSender(), "PageCommunity: wrong owner");

        nft.burn(owner);
        erasePost(postId, owner);
        community[communityId].postIds.remove(postId);

        emit BurnPost(communityId, postId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        bank.burnTokenForBurnPost(_msgSender(), owner, gas);
    }

    function setVisibilityPost(
        uint256 postId,
        bool newVisible
    ) external onlyCommunityActive(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(community[communityId].moderators.contains(_msgSender()), "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = post[postId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        post[postId].isView = newVisible;

        emit ChangeVisiblePost(communityId, postId, newVisible);
    }

    function getPostPrice(uint256 postId) public view returns (uint256) {
        return post[postId].price;
    }

    function getPostsIdsByCommunityId(uint256 communityId) public view override returns (uint256[] memory) {
        return community[communityId].postIds.values();
    }

    function writeComment(
        uint256 postId,
        string memory ipfsHash,
        bool isUp,
        bool isDown,
        address owner
    ) external onlyCommunityActive(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(community[communityId].users.contains(_msgSender()), "PageCommunity: wrong user");
        require(community[communityId].users.contains(owner), "PageCommunity: wrong user");
        require(post[postId].isView, "PageCommunity: wrong view post");

        incCommentCount(postId);
        setPostUpDown(isUp, isDown);
        createComment(postId, ipfsHash, owner, isUp, isDown);
        uint256 commentId = getCurrentCommentCount(postId);

        emit WriteComment(communityId, postId, commentId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.mintTokenForNewPost(_msgSender(), owner, gas);
        setCommentPrice(postId, commentId, price);
    }

    function readComment(uint256 postId, uint256 commentId) external view onlyCommunityActive(postId) returns(
        string ipfsHash,
        address creator,
        address owner,
        uint128 price,
        bool isUp,
        bool isDown,
        bool isView
    ) {
        Comment memory readed = comment[postId][commentId];
        ipfsHash = readed.ipfsHash;
        creator = readed.creator;
        owner = readed.owner;
        price = readed.price;
        isUp = readed.isUp;
        isDown = readed.isDown;
        isView = readed.isView;
    }

    function burnComment(uint256 postId, uint256 commentId) external onlyCommunityActive(postId) {
        require(post[postId].isView, "PageCommunity: wrong post");
        require(community[id].moderators.contains(_msgSender()), "PageCommunity: access denied");

        eraseComment(postId, commentId);
        emit BurnComment(postId, commentId, );
    }

    function setVisibilityComment(
        uint256 postId,
        uint256 commentId,
        bool newVisible
    ) external onlyCommunityActive(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(community[communityId].moderators.contains(_msgSender()), "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = comment[postId][commentId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        post[postId][commentId].isView = newVisible;

        emit ChangeVisibleComment(communityId, postId, newVisible);
    }

    function getCurrentCommentCount(uint256 postId) public returns(uint256) {
        Post memory curPost = post[postId];
        return curPost.commentCount;
    }

    function getCommunityIdByPostId(uint256 postId) public returns(uint256) {
        return communityIdByPostId[postId];
    }

    //private area

    function validateCommunity(uint256 communityId) private {
        require(number <= communityCount, "PageCommunity: wrong community number");
    }

    function createPost(uint256 postId, address owner, string memory ipfsHash) private {
        Post storage newPost = post[postId];
        newPost.ipfsHash = ipfsHash;
        newPost.creator = _msgSender();
        newPost.owner = owner;
        newPost.isView = true;
    }

    function erasePost(uint256 postId) private {
        Post storage oldPost = post[postId];
        oldPost.ipfsHash = EMPTY_STRING;
        oldPost.creator = address(0);
        oldPost.owner = address(0);
        oldPost.downCount = 0;
        oldPost.upCount = 0;
        oldPost.commentCount = 0;
        oldPost.isView = false;
    }

    function eraseComment(uint256 postId, uint256 commentId) private {
        Comment storage burned = comment[postId][commentId];
        burned.ipfsHash = EMPTY_STRING;
        burned.creator = address(0);
        burned.owner = address(0);
        burned.price = 0;
        burned.isUp = false;
        burned.isDown = false;
        burned.isView = false;
    }

    function setPostPrice(uint256 postId, uint256 price) private {
        Post storage curPost = post[postId];
        curPost.price = price;
    }

    function incCommentCount(uint256 postId) private {
        Post storage curPost = post[postId];
        curPost.commentCount++;
    }

    function setPostUpDown(bool isUp, bool isDown) private {
        require(!(isUpCount && isUpCount == isDownCount), "PageCommunity: wrong Up/Down");

        Post storage curPost = post[postId];
        if (isUp) {
            curPost.upCount++;
        }
        if (isDown) {
            curPost.downCount++;
        }
    }

    function createComment(uint256 postId, string memory ipfsHash, address owner, bool isUp, bool isDown) private {
        uint256 commentId = post[postId].commentCount;
        Comment storage newComment = comment[postId][commentId];
        newComment.ipfsHash = ipfsHash;
        newComment.creator = _msgSender();
        newComment.owner = owner;
        newComment.isUp = isUp;
        newComment.isDown = isDown;
        newComment.isView = true;
    }

    function setCommentPrice(uint256 postId, uint256 commentId, uint256 price) private {
        Comment storage curComment = comment[postId][commentId];
        curComment.price = price;
    }

    function isActiveCommunityByPostId(uint256 postId) public returns(uint256) {
        uint256 communityId = communityIdByPostId[postId];
        return community[communityId].active;
    }
}
