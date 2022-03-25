// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";

import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageCommunity.sol";


/// @title The contract for manage community
/// @author Crypto.Page Team
/// @notice
/// @dev 
contract PageCommunity is
Initializable,
OwnableUpgradeable,
AccessControlUpgradeable,
IPageCommunity
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    IPageNFT public nft;
    IPageBank public bank;

    uint256 public MAX_MODERATORS = 40;
    uint256 private WRONG_MODERATOR_NUMBER = 1000;

    string public EMPTY_STRING = '';

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
        EnumerableSetUpgradeable.AddressSet upDownUsers;
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
        require(isCommunityUser(id, _msgSender()), "PageCommunity: wrong user");
        _;
    }

    modifier onlyCommunityActive(uint256 postId) {
        require(isActiveCommunityByPostId(postId), "PageCommunity: wrong active community");
        _;
    }

    function initialize(address _nft, address _bank) public initializer {
        require(_nft != address(0), "PageCommunity: Wrong _nft address");
        require(_bank != address(0), "PageCommunity: Wrong _bank address");
        __Ownable_init();
        nft = IPageNFT(_nft);
        bank = IPageBank(_bank);
    }

    function version() public pure override returns (string memory) {
        return "1";
    }

    function addCommunity(string memory desc) external override {
        communityCount++;
        Community storage newCommunity = community[communityCount];
        newCommunity.creator = _msgSender();
        newCommunity.active = true;
        newCommunity.name = desc;

        emit AddedCommunity(_msgSender(), communityCount, desc);
    }

    function readCommunity(uint256 communityId) external view override validId(communityId) returns(
        string memory name,
        address creator,
        address[] memory moderators,
        uint256[] memory postIds,
        address[] memory users,
        uint256 usersCount,
        bool active
    ) {

        Community storage currentCommunity = community[communityId];

        name = currentCommunity.name;
        creator = currentCommunity.creator;
        moderators = currentCommunity.moderators.values();
        postIds = currentCommunity.postIds.values();
        users = currentCommunity.users.values();
        usersCount = currentCommunity.usersCount;
        active = currentCommunity.active;
    }

    function addModerator(uint256 communityId, address moderator) external override validId(communityId) {
        Community storage currentCommunity = community[communityId];
        require(moderator != address(0), "PageCommunity: Wrong moderator");
        require(currentCommunity.moderators.length() < MAX_MODERATORS, "PageCommunity: The limit on the number of moderators");

        currentCommunity.moderators.add(moderator);
        emit AddedModerator(_msgSender(), communityId, moderator);
    }

    function removeModerator(uint256 communityId, address moderator) external override validId(communityId) {
        Community storage currentCommunity = community[communityId];
        require(_msgSender() == currentCommunity.creator, "PageCommunity: Wrong creator");

        currentCommunity.moderators.remove(moderator);
        emit RemovedModerator(_msgSender(), communityId, moderator);
    }

    function join(uint256 communityId) external override validId(communityId) {
        community[communityId].users.add(_msgSender());
        community[communityId].usersCount++;
        emit JoinUser(communityId, _msgSender());
    }

    function quit(uint256 communityId) external override validId(communityId) {
        community[communityId].users.remove(_msgSender());
        community[communityId].usersCount--;
        emit QuitUser(communityId, _msgSender());
    }

    function writePost(
        uint256 communityId,
        string memory ipfsHash,
        address owner
    ) external override validId(communityId) onlyCommunityUser(communityId) {
        uint256 gasBefore = gasleft();

        require(community[communityId].active, "PageCommunity: wrong active community");
        require(isCommunityUser(communityId, _msgSender()), "PageCommunity: wrong user");
        require(isCommunityUser(communityId, owner), "PageCommunity: wrong user");

        uint256 postId = nft.mint(owner);
        createPost(postId, owner, ipfsHash);

        community[communityId].postIds.add(postId);
        communityIdByPostId[postId] = communityId;
        emit WritePost(communityId, postId, _msgSender(), owner);

        require(bank.definePostFeeForNewCommunity(communityId), "PageCommunity: wrong define post fee");
        require(bank.defineCommentFeeForNewCommunity(communityId), "PageCommunity: wrong define comment fee");

        uint256 gas = gasBefore - gasleft();
        uint128 price = uint128(bank.mintTokenForNewPost(communityId, owner, _msgSender(), gas));
        setPostPrice(postId, price);
    }

    function readPost(uint256 postId) external view override onlyCommunityActive(postId) returns(
        string memory ipfsHash,
        address creator,
        address owner,
        uint64 upCount,
        uint64 downCount,
        uint128 price,
        uint256 commentCount,
        address[] memory upDownUsers,
        bool isView
    ) {
        Post storage readed = post[postId];
        ipfsHash = readed.ipfsHash;
        creator = readed.creator;
        owner = readed.owner;
        upCount = readed.upCount;
        downCount = readed.downCount;
        price = readed.price;
        commentCount = readed.commentCount;
        upDownUsers = readed.upDownUsers.values();
        isView = readed.isView;
    }

    function burnPost(uint256 postId) external override onlyCommunityActive(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);
        address postOwner = post[postId].owner;

        require(isCommunityUser(communityId, _msgSender()), "PageCommunity: wrong user");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");
        require(postOwner == _msgSender(), "PageCommunity: wrong owner");

        nft.burn(postId);
        erasePost(postId);
        community[communityId].postIds.remove(postId);

        emit BurnPost(communityId, postId, _msgSender(), postOwner);

        uint256 gas = gasBefore - gasleft();
        bank.burnTokenForPost(communityId, postOwner, _msgSender(), gas);
    }

    function setVisibilityPost(uint256 postId, bool newVisible) external override onlyCommunityActive(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(isCommunityModerator(communityId, _msgSender()), "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = post[postId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        post[postId].isView = newVisible;

        emit ChangeVisiblePost(communityId, postId, newVisible);
    }

    function getPostPrice(uint256 postId) external view override returns (uint256) {
        return post[postId].price;
    }

    function getPostsIdsByCommunityId(uint256 communityId) external view override returns (uint256[] memory) {
        return community[communityId].postIds.values();
    }

    function writeComment(
        uint256 postId,
        string memory ipfsHash,
        bool isUp,
        bool isDown,
        address owner
    ) external override onlyCommunityActive(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(isCommunityUser(communityId, _msgSender()), "PageCommunity: wrong user");
        require(isCommunityUser(communityId, owner), "PageCommunity: wrong user");
        require(post[postId].isView, "PageCommunity: wrong view post");

        incCommentCount(postId);
        setPostUpDown(postId, isUp, isDown);
        createComment(postId, ipfsHash, owner, isUp, isDown);
        uint256 commentId = getCommentCount(postId);

        emit WriteComment(communityId, postId, commentId, _msgSender(), owner);

        uint256 gas = gasBefore - gasleft();
        uint128 price = uint128(bank.mintTokenForNewComment(communityId, owner, _msgSender(), gas));
        setCommentPrice(postId, commentId, price);
    }

    function readComment(uint256 postId, uint256 commentId) external view override onlyCommunityActive(postId) returns(
        string memory ipfsHash,
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

    function burnComment(uint256 postId, uint256 commentId) external override onlyCommunityActive(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(post[postId].isView, "PageCommunity: wrong post");
        require(isCommunityModerator(communityId, _msgSender()), "PageCommunity: access denied");
        address commentOwner = comment[postId][commentId].owner;
        address commentCreator = comment[postId][commentId].creator;
        eraseComment(postId, commentId);
        emit BurnComment(communityId, postId, commentId, commentCreator, commentOwner);

        uint256 gas = gasBefore - gasleft();
        bank.burnTokenForComment(communityId, commentOwner, _msgSender(), gas);
    }

    function setVisibilityComment(
        uint256 postId,
        uint256 commentId,
        bool newVisible
    ) external override onlyCommunityActive(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(isCommunityModerator(communityId, _msgSender()), "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = comment[postId][commentId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        comment[postId][commentId].isView = newVisible;

        emit ChangeVisibleComment(communityId, postId, commentId, newVisible);
    }

    function getCommentCount(uint256 postId) public view override returns(uint256) {
        return post[postId].commentCount;
    }

    function isCommunityCreator(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].creator == user;
    }

    function isCommunityUser(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].users.contains(user);
    }

    function isCommunityModerator(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].moderators.contains(user);
    }

    function getCommunityIdByPostId(uint256 postId) public view override returns(uint256) {
        return communityIdByPostId[postId];
    }

    function isUpDownUser(uint256 postId, address user) public view override returns(bool) {
        return post[postId].upDownUsers.contains(user);
    }

    function isActiveCommunityByPostId(uint256 postId) public view override returns(bool) {
        uint256 communityId = communityIdByPostId[postId];
        return community[communityId].active;
    }

    //private area

    function validateCommunity(uint256 communityId) private view {
        require(communityId <= communityCount, "PageCommunity: wrong community number");
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

    function setPostPrice(uint256 postId, uint128 price) private {
        Post storage curPost = post[postId];
        curPost.price = price;
    }

    function incCommentCount(uint256 postId) private {
        Post storage curPost = post[postId];
        curPost.commentCount++;
    }

    function setPostUpDown(uint256 postId, bool isUp, bool isDown) private {
        if (!isUp && !isDown) {
            return;
        }
        require(!(isUp && isUp == isDown), "PageCommunity: wrong values for Up/Down");
        require(!isUpDownUser(postId, _msgSender()), "PageCommunity: wrong user for Up/Down");

        Post storage curPost = post[postId];
        if (isUp) {
            curPost.upCount++;
        }
        if (isDown) {
            curPost.downCount++;
        }
        curPost.upDownUsers.add(_msgSender());
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

    function setCommentPrice(uint256 postId, uint256 commentId, uint128 price) private {
        Comment storage curComment = comment[postId][commentId];
        curComment.price = price;
    }
}