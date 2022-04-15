// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";

import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageCommunity.sol";


     /**
     * @dev The contract for manage community
     *
     */
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
    string public EMPTY_STRING = '';

    address public supervisor;
    address[] public voterContracts;

    uint256 public communityCount;

    struct Community {
        string name;
        address creator;
        EnumerableSetUpgradeable.AddressSet moderators;
        EnumerableSetUpgradeable.UintSet postIds;
        EnumerableSetUpgradeable.AddressSet users;
        EnumerableSetUpgradeable.AddressSet bannedUsers;
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

    event AddedBannedUser(address indexed admin, uint256 number, address user);
    event RemovedBannedUser(address indexed admin, uint256 number, address user);

    event JoinUser(uint256 indexed communityId, address user);
    event QuitUser(uint256 indexed communityId, address user);

    event WritePost(uint256 indexed communityId, uint256 postId, address creator, address owner);
    event BurnPost(uint256 indexed communityId, uint256 postId, address creator, address owner);
    event ChangePostVisible(uint256 indexed communityId, uint256 postId, bool isVisible);
    event ChangeCommunityActive(uint256 indexed communityId, bool isActive);

    event WriteComment(uint256 indexed communityId, uint256 postId, uint256 commentId, address creator, address owner);
    event BurnComment(uint256 indexed communityId, uint256 postId, uint256 commentId, address creator, address owner);
    event ChangeVisibleComment(uint256 indexed communityId, uint256 postId, uint256 commentId, bool isVisible);

    event SetMaxModerators(uint256 oldValue, uint256 newValue);
    event ChangeSupervisor(address oldValue, address newValue);

    modifier validCommunityId(uint256 id) {
        validateCommunity(id);
        require(isActiveCommunity(id), "PageCommunity: wrong active community");
        _;
    }

    modifier onlyCommunityUser(uint256 id) {
        validateCommunity(id);
        require(isCommunityUser(id, _msgSender()), "PageCommunity: wrong user");
        _;
    }

    modifier onlyVoterContract(uint256 id) {
        require(_msgSender() == voterContracts[id], "PageCommunity: wrong user");
        _;
    }

    modifier onlyCommunityActiveByPostId(uint256 postId) {
        require(isActiveCommunityByPostId(postId), "PageCommunity: wrong active community");
        _;
    }

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _nft NFT contract address
     * @param _bank Bank contract address
     * @param _admin Address of admin
     */
    function initialize(address _nft, address _bank, address _admin) public initializer {
        require(_nft != address(0), "PageCommunity: Wrong _nft address");
        require(_bank != address(0), "PageCommunity: Wrong _bank address");
        require(_admin != address(0), "PageCommunity: Wrong _admin address");

        __Ownable_init();
        nft = IPageNFT(_nft);
        bank = IPageBank(_bank);

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() public pure override returns (string memory) {
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

    /**
     * @dev Creates a new community.
     *
     * @param desc Text description for the community
     */
    function addCommunity(string memory desc) external override {
        communityCount++;
        Community storage newCommunity = community[communityCount];
        newCommunity.creator = _msgSender();
        newCommunity.active = true;
        newCommunity.name = desc;

        emit AddedCommunity(_msgSender(), communityCount, desc);
    }

    /**
     * @dev Returns information about the community.
     *
     * @param communityId ID of community
     */
    function readCommunity(uint256 communityId) external view override validCommunityId(communityId) returns(
        string memory name,
        address creator,
        address[] memory moderators,
        uint256[] memory postIds,
        address[] memory users,
        address[] memory bannedUsers,
        uint256 usersCount,
        bool active
    ) {

        Community storage currentCommunity = community[communityId];

        name = currentCommunity.name;
        creator = currentCommunity.creator;
        moderators = currentCommunity.moderators.values();
        postIds = currentCommunity.postIds.values();
        users = currentCommunity.users.values();
        bannedUsers = currentCommunity.bannedUsers.values();
        usersCount = currentCommunity.usersCount;
        active = currentCommunity.active;
    }

    /**
     * @dev Adds a moderator for the community.
     * Can only be done by voting.
     *
     * @param communityId ID of community
     * @param moderator User address
     */
    function addModerator(uint256 communityId, address moderator) external override validCommunityId(communityId) onlyVoterContract(0) {
        Community storage currentCommunity = community[communityId];

        require(moderator != address(0), "PageCommunity: Wrong moderator");
        require(currentCommunity.moderators.length() < MAX_MODERATORS, "PageCommunity: The limit on the number of moderators");
        require(isCommunityUser(communityId, moderator), "PageCommunity: wrong user");

        currentCommunity.moderators.add(moderator);
        emit AddedModerator(_msgSender(), communityId, moderator);
    }

    /**
     * @dev Removes a moderator for the community.
     * Can only be done by voting.
     *
     * @param communityId ID of community
     * @param moderator User address
     */
    function removeModerator(uint256 communityId, address moderator) external override validCommunityId(communityId) onlyVoterContract(0) {
        Community storage currentCommunity = community[communityId];

        require(isCommunityModerator(communityId, moderator), "PageCommunity: wrong moderator");

        currentCommunity.moderators.remove(moderator);
        emit RemovedModerator(_msgSender(), communityId, moderator);
    }

    /**
     * @dev Adds a banned user for the community.
     * Can only be done by moderator.
     *
     * @param communityId ID of community
     * @param user User address
     */
    function addBannedUser(uint256 communityId, address user) external override validCommunityId(communityId) {
        Community storage currentCommunity = community[communityId];

        require(isCommunityModerator(communityId, _msgSender()), "PageCommunity: access denied");
        require(isCommunityUser(communityId, user), "PageCommunity: wrong user");
        require(!isBannedUser(communityId, user), "PageCommunity: user is already banned");

        currentCommunity.bannedUsers.add(user);
        emit AddedBannedUser(_msgSender(), communityId, user);
    }

    /**
     * @dev Removes a banned user for the community.
     * Can only be done by moderator.
     *
     * @param communityId ID of community
     * @param user User address
     */
    function removeBannedUser(uint256 communityId, address user) external override validCommunityId(communityId) {
        Community storage currentCommunity = community[communityId];

        require(isCommunityModerator(communityId, _msgSender()), "PageCommunity: access denied");
        require(isCommunityUser(communityId, user), "PageCommunity: wrong user");
        require(isBannedUser(communityId, user), "PageCommunity: user is already banned");

        currentCommunity.bannedUsers.remove(user);
        emit RemovedBannedUser(_msgSender(), communityId, user);
    }

    /**
     * @dev Entry of a new user into the community.
     *
     * @param communityId ID of community
     */
    function join(uint256 communityId) external override validCommunityId(communityId) {
        community[communityId].users.add(_msgSender());
        community[communityId].usersCount++;
        emit JoinUser(communityId, _msgSender());
    }

    /**
     * @dev Exit of a user from the community.
     *
     * @param communityId ID of community
     */
    function quit(uint256 communityId) external override validCommunityId(communityId) {
        community[communityId].users.remove(_msgSender());
        community[communityId].usersCount--;
        emit QuitUser(communityId, _msgSender());
    }

    /**
     * @dev Create a new community post.
     *
     * @param communityId ID of community
     * @param ipfsHash Link to the message in IPFS
     * @param owner Post owner address
     */
    function writePost(
        uint256 communityId,
        string memory ipfsHash,
        address owner
    ) external override validCommunityId(communityId) onlyCommunityUser(communityId) {
        uint256 gasBefore = gasleft();

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

    /**
     * @dev Returns information about the post.
     *
     * @param postId ID of post
     */
    function readPost(uint256 postId) external view override onlyCommunityActiveByPostId(postId) returns(
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

    /**
     * @dev Removes information about the post.
     *
     * @param postId ID of post
     */
    function burnPost(uint256 postId) external override onlyCommunityActiveByPostId(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);
        address postOwner = post[postId].owner;

        require(isCommunityUser(communityId, _msgSender()) || _msgSender() == supervisor, "PageCommunity: wrong user");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");
        require(postOwner == _msgSender(), "PageCommunity: wrong owner");

        nft.burn(postId);
        erasePost(postId);
        community[communityId].postIds.remove(postId);

        emit BurnPost(communityId, postId, _msgSender(), postOwner);

        uint256 gas = gasBefore - gasleft();
        bank.burnTokenForPost(communityId, postOwner, _msgSender(), gas);
    }

    /**
     * @dev Change post visibility.
     *
     * @param postId ID of post
     * @param newVisible Boolean value for post visibility
     */
    function setPostVisibility(uint256 postId, bool newVisible) external override onlyCommunityActiveByPostId(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(isCommunityModerator(communityId, _msgSender()) || _msgSender() == supervisor, "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = post[postId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        post[postId].isView = newVisible;

        emit ChangePostVisible(communityId, postId, newVisible);
    }

    /**
     * @dev Change community active.
     *
     * @param communityId ID of community
     * @param newActive Boolean value for community active
     */
    function setCommunityActive(uint256 communityId, bool newActive) external override {
        require(supervisor == _msgSender(), "PageCommunity: wrong supervisor");

        bool oldActive = community[communityId].active;
        require(oldActive != newActive, "PageCommunity: wrong new active");
        community[communityId].active = newActive;

        emit ChangeCommunityActive(communityId, newActive);
    }

    /**
     * @dev Returns the cost of a post in Page tokens.
     *
     * @param postId ID of post
     */
    function getPostPrice(uint256 postId) external view override returns (uint256) {
        return post[postId].price;
    }

    /**
     * @dev Returns an array of post IDs created in the community.
     *
     * @param communityId ID of community
     */
    function getPostsIdsByCommunityId(uint256 communityId) external view override returns (uint256[] memory) {
        return community[communityId].postIds.values();
    }

    /**
     * @dev Create a new post comment.
     *
     * @param postId ID of post
     * @param ipfsHash Link to the message in IPFS
     * @param isUp If true, then adds a rating for the post
     * @param isDown If true, then removes a rating for the post
     * @param owner Comment owner address
     */
    function writeComment(
        uint256 postId,
        string memory ipfsHash,
        bool isUp,
        bool isDown,
        address owner
    ) external override onlyCommunityActiveByPostId(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(isCommunityUser(communityId, _msgSender()), "PageCommunity: wrong user");
        require(isCommunityUser(communityId, owner), "PageCommunity: wrong user");
        require(post[postId].isView, "PageCommunity: wrong view post");

        setPostUpDown(postId, isUp, isDown);
        createComment(postId, ipfsHash, owner, isUp, isDown);
        uint256 commentId = getCommentCount(postId);

        emit WriteComment(communityId, postId, commentId, _msgSender(), owner);
        incCommentCount(postId);

        uint256 gas = gasBefore - gasleft();
        uint128 price = uint128(bank.mintTokenForNewComment(communityId, owner, _msgSender(), gas));
        setCommentPrice(postId, commentId, price);
    }

    /**
     * @dev Returns information about the comment.
     *
     * @param postId ID of post
     * @param commentId ID of comment
     */
    function readComment(uint256 postId, uint256 commentId) external view override onlyCommunityActiveByPostId(postId) returns(
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

    /**
     * @dev Removes information about the comment.
     *
     * @param postId ID of post
     * @param commentId ID of comment
     */
    function burnComment(uint256 postId, uint256 commentId) external override onlyCommunityActiveByPostId(postId) {
        uint256 gasBefore = gasleft();
        uint256 communityId = getCommunityIdByPostId(postId);

        require(post[postId].isView, "PageCommunity: wrong post");
        require(isCommunityModerator(communityId, _msgSender()) || _msgSender() == supervisor, "PageCommunity: access denied");
        address commentOwner = comment[postId][commentId].owner;
        address commentCreator = comment[postId][commentId].creator;
        eraseComment(postId, commentId);
        emit BurnComment(communityId, postId, commentId, commentCreator, commentOwner);

        uint256 gas = gasBefore - gasleft();
        bank.burnTokenForComment(communityId, commentOwner, _msgSender(), gas);
    }

    /**
     * @dev Change comment visibility.
     *
     * @param postId ID of post
     * @param commentId ID of comment
     * @param newVisible Boolean value for comment visibility
     */
    function setVisibilityComment(
        uint256 postId,
        uint256 commentId,
        bool newVisible
    ) external override onlyCommunityActiveByPostId(postId) {
        uint256 communityId = getCommunityIdByPostId(postId);
        require(isCommunityModerator(communityId, _msgSender()) || _msgSender() == supervisor, "PageCommunity: access denied");
        require(community[communityId].postIds.contains(postId), "PageCommunity: wrong post");

        bool oldVisible = comment[postId][commentId].isView;
        require(oldVisible != newVisible, "PageCommunity: wrong new visible");
        comment[postId][commentId].isView = newVisible;

        emit ChangeVisibleComment(communityId, postId, commentId, newVisible);
    }

    /**
     * @dev Changes MAX_MODERATORS value for all new communities.
     *
     * @param newValue New MAX_MODERATORS value
     */
    function setMaxModerators(uint256 newValue) external override onlyOwner {
        require(MAX_MODERATORS != newValue, "PageCommunity: wrong new value");
        emit SetMaxModerators(MAX_MODERATORS, newValue);
        MAX_MODERATORS = newValue;
    }

    /**
     * @dev Adds address for voter contracts array
     *
     * @param newContract New voter contract address
     */
    function addVoterContract(address newContract) external override onlyOwner {
        require(newContract != address(0), "PageCommunity: value is zero");
        voterContracts.push(newContract);
    }

    /**
     * @dev Changes address for supervisor user
     *
     * @param newUser New supervisor address
     */
    function changeSupervisor(address newUser) external override onlyVoterContract(1) {
        emit ChangeSupervisor(supervisor, newUser);
        supervisor = newUser;
    }

    /**
     * @dev Returns the number of comments for a post.
     *
     * @param postId ID of post
     */
    function getCommentCount(uint256 postId) public view override returns(uint256) {
        return post[postId].commentCount;
    }

    /**
     * @dev Returns a boolean value about checking the address of the creator of the community.
     *
     * @param communityId ID of community
     * @param user Community creator address
     */
    function isCommunityCreator(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].creator == user;
    }

    /**
     * @dev Returns a boolean value about checking the address of the user of the community.
     *
     * @param communityId ID of community
     * @param user Community user address
     */
    function isCommunityUser(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].users.contains(user) && !isBannedUser(communityId, user);
    }

    /**
     * @dev Returns a boolean value about checking the address of the user of the banned.
     *
     * @param communityId ID of community
     * @param user Community user address
     */
    function isBannedUser(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].bannedUsers.contains(user);
    }

    /**
     * @dev Returns a boolean value about checking the address of the moderator of the community.
     *
     * @param communityId ID of community
     * @param user Community moderator address
     */
    function isCommunityModerator(uint256 communityId, address user) public view override returns(bool) {
        return community[communityId].moderators.contains(user);
    }

    /**
     * @dev Returns the community ID given the post ID.
     *
     * @param postId ID of post
     */
    function getCommunityIdByPostId(uint256 postId) public view override returns(uint256) {
        return communityIdByPostId[postId];
    }

    /**
     * @dev Returns a boolean indicating that the user has already upvoted or downvoted the post.
     *
     * @param postId ID of post
     * @param user Community user address
     */
    function isUpDownUser(uint256 postId, address user) public view override returns(bool) {
        return post[postId].upDownUsers.contains(user);
    }

    /**
     * @dev Returns a boolean indicating that the community is active.
     *
     * @param communityId ID of community
     */
    function isActiveCommunity(uint256 communityId) public view override returns(bool) {
        return community[communityId].active;
    }

    /**
     * @dev Returns a boolean indicating that the community is active for this post.
     *
     * @param postId ID of post
     */
    function isActiveCommunityByPostId(uint256 postId) public view override returns(bool) {
        uint256 communityId = communityIdByPostId[postId];
        return community[communityId].active;
    }

    //private area

    /**
     * @dev Checks if such an ID can exist for the community.
     *
     * @param communityId ID of community
     */
    function validateCommunity(uint256 communityId) private view {
        require(communityId <= communityCount, "PageCommunity: wrong community number");
    }

    /**
     * @dev Create a new community post.
     *
     * @param postId ID of post
     * @param owner Post owner address
     * @param ipfsHash Link to the message in IPFS
     */
    function createPost(uint256 postId, address owner, string memory ipfsHash) private {
        Post storage newPost = post[postId];
        newPost.ipfsHash = ipfsHash;
        newPost.creator = _msgSender();
        newPost.owner = owner;
        newPost.isView = true;
    }

    /**
     * @dev Erase info for the community post.
     *
     * @param postId ID of post
     */
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

    /**
     * @dev Erase info for the post comment.
     *
     * @param postId ID of post
     * @param commentId ID of comment
     */
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

    /**
     * @dev Sets price for post.
     *
     * @param postId ID of post
     * @param price The price value
     */
    function setPostPrice(uint256 postId, uint128 price) private {
        Post storage curPost = post[postId];
        curPost.price = price;
    }

    /**
     * @dev Increases the comment count for a post.
     *
     * @param postId ID of post
     */
    function incCommentCount(uint256 postId) private {
        Post storage curPost = post[postId];
        curPost.commentCount++;
    }

    /**
     * @dev Sets rating for post.
     *
     * @param postId ID of post
     * @param isUp If true, then adds a rating for the post
     * @param isDown If true, then removes a rating for the post
     */
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

    /**
     * @dev Create a new post comment.
     *
     * @param postId ID of post
     * @param ipfsHash Link to the message in IPFS
     * @param owner Post owner address
     * @param isUp If true, then adds a rating for the post
     * @param isDown If true, then removes a rating for the post
     */
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

    /**
     * @dev Sets price for comment.
     *
     * @param postId ID of post
     * @param commentId ID of comment
     * @param price The price value
     */
    function setCommentPrice(uint256 postId, uint256 commentId, uint128 price) private {
        Comment storage curComment = comment[postId][commentId];
        curComment.price = price;
    }
}