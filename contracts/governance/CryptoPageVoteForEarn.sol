// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";

import "../interfaces/ICryptoPageBank.sol";
import "../interfaces/ICryptoPageCommunity.sol";
import "../interfaces/ICryptoPageToken.sol";
import "../interfaces/ICryptoPageVoteForEarn.sol";

contract PageVoteForEarn is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable,
    IPageVoteForEarn
{

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    uint128 public MIN_DURATION = 1 days;
    uint128 public MIN_MODERATOR_COUNT = 10;

    IPageCommunity community;
    IPageBank public bank;
    IPageToken public token;

    struct UintValueVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint128 newPrice;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    struct UintAddressValueVote {
        string description;
        address creator;
        uint128 finishTime;
        uint128 yesCount;
        uint128 noCount;
        uint128 value;
        address wallet;
        EnumerableSetUpgradeable.AddressSet voteUsers;
        bool active;
    }

    //communityId -> UintValueVote[]
    mapping(uint256 => UintValueVote[]) private privacyAccessPriceVotes;
    mapping(uint256 => UintAddressValueVote[]) private tokenTransferVotes;
    mapping(uint256 => UintAddressValueVote[]) private nftTransferVotes;
    mapping(uint256 => uint256) private lastVoteBlock;

    event SetMinDuration(uint256 oldValue, uint256 newValue);

    event PutPrivacyAccessPriceVote(address indexed sender, uint256 communityId, uint256 index, bool isYes, uint256 weight);
    event PutTokenTransferVote(address indexed sender, uint256 communityId, uint256 index, bool isYes, uint256 weight);
    event PutNftTransferVote(address indexed sender, uint256 communityId, uint256 index, bool isYes, uint256 weight);

    event CreatePrivacyAccessPriceVote(address indexed sender, uint128 duration, uint128 newPrice);
    event CreateTokenTransferVote(address indexed sender, uint128 duration, uint128 amount, address wallet);
    event CreateNftTransferVote(address indexed sender, uint128 duration, uint128 id, address wallet);

    event ExecutePrivacyAccessPriceVote(address sender, uint256 communityId, uint256 index);
    event ExecuteTokenTransferVote(address sender, uint256 communityId, uint256 index);
    event ExecuteNftTransferVote(address sender, uint256 communityId, uint256 index);

    function initialize(address _admin, address _token, address _community, address _bank) public initializer {
        __Ownable_init();
        require(_admin != address(0), "PageVote: wrong admin address");
        require(_token != address(0), "PageVote: wrong token address");
        require(_community != address(0), "PageVote: wrong community address");
        require(_bank != address(0), "PageCommunity: wrong bank address");

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);

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
     * @dev Creates a new community vote proposal for price of privacy access.
     *
     * @param communityId ID of community
     * @param description Brief text description for the proposal
     * @param duration Voting duration in seconds
     * @param newPrice Value for new price
     */
    function createPrivacyAccessPriceVote (
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint128 newPrice
    ) external override {
        require(duration >= MIN_DURATION, "PageVote: wrong duration");
        address sender = _msgSender();
        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");

        uint256 len = readPrivacyAccessPriceVotesCount(communityId);
        if (len > 0) {
            require(!privacyAccessPriceVotes[communityId][len-1].active, "PageVote: previous voting has not finished");
        }
        privacyAccessPriceVotes[communityId].push();

        UintValueVote storage vote = privacyAccessPriceVotes[communityId][len];
        vote.description = description;
        vote.creator = sender;
        vote.finishTime = uint128(block.timestamp) + duration;
        vote.newPrice = newPrice;
        vote.active = true;

        emit CreatePrivacyAccessPriceVote(sender, duration, newPrice);
    }

    /**
 * @dev Creates a new community vote proposal for price of privacy access.
     *
     * @param communityId ID of community
     * @param description Brief text description for the proposal
     * @param duration Voting duration in seconds
     * @param amount Value for amount of tokens
     * @param wallet Address for transferring tokens
     */
    function createTokenTransferVote (
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint128 amount,
        address wallet
    ) external override {
        require(duration >= MIN_DURATION, "PageVote: wrong duration");
        address sender = _msgSender();
        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");

        uint256 len = readTokenTransferVotesCount(communityId);
        if (len > 0) {
            require(!tokenTransferVotes[communityId][len-1].active, "PageVote: previous voting has not finished");
        }
        tokenTransferVotes[communityId].push();

        UintAddressValueVote storage vote = tokenTransferVotes[communityId][len];
        createTransferVote(vote, description, sender, duration, amount, wallet);

        emit CreateTokenTransferVote(sender, duration, amount, wallet);
    }

    function createNftTransferVote (
        uint256 communityId,
        string memory description,
        uint128 duration,
        uint128 id,
        address wallet
    ) external override {
        require(duration >= MIN_DURATION, "PageVote: wrong duration");
        address sender = _msgSender();
        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");

        uint256 len = readNftTransferVotesCount(communityId);
        if (len > 0) {
            require(!nftTransferVotes[communityId][len-1].active, "PageVote: previous voting has not finished");
        }
        nftTransferVotes[communityId].push();

        UintAddressValueVote storage vote = nftTransferVotes[communityId][len];
        createTransferVote(vote, description, sender, duration, id, wallet);

        emit CreateNftTransferVote(sender, duration, id, wallet);
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
    function putPrivacyAccessPriceVote(uint256 communityId, uint256 index, bool isYes) external override {
        require(privacyAccessPriceVotes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        UintValueVote storage vote = privacyAccessPriceVotes[communityId][index];

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

        emit PutPrivacyAccessPriceVote(sender, communityId, index, isYes, weight);
    }

    /**
     * @dev Here the user votes either for the implementation of the proposal or against.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     * @param isYes For the implementation of the proposal or against the implementation
     */
    function putTokenTransferVote(uint256 communityId, uint256 index, bool isYes) external override {
        require(tokenTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = tokenTransferVotes[communityId][index];
        uint256 weight = putTransferVote(communityId, vote, isYes);

        emit PutTokenTransferVote(_msgSender(), communityId, index, isYes, weight);
    }

    /**
     * @dev Here the user votes either for the implementation of the proposal or against.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     * @param isYes For the implementation of the proposal or against the implementation
     */
    function putNftTransferVote(uint256 communityId, uint256 index, bool isYes) external override {
        require(nftTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = nftTransferVotes[communityId][index];
        uint256 weight = putTransferVote(communityId, vote, isYes);

        emit PutNftTransferVote(_msgSender(), communityId, index, isYes, weight);
    }

    /**
     * @dev Starts the execution of a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executePrivacyAccessPriceVote(uint256 communityId, uint256 index) external override {
        require(privacyAccessPriceVotes[communityId].length > index, "PageVote: wrong index");

        address sender = _msgSender();
        UintValueVote storage vote = privacyAccessPriceVotes[communityId][index];

        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");
        require(vote.voteUsers.contains(sender), "PageVote: the user did not vote");
        require(vote.active, "PageVote: vote not active");
        require(vote.finishTime < block.timestamp, "PageVote: wrong time");

        if (vote.yesCount > vote.noCount) {
            executePrivacyAccessPriceVoteScript(communityId, uint256(vote.newPrice));
        }

        vote.active = false;

        emit ExecutePrivacyAccessPriceVote(sender, communityId, index);
    }

    /**
     * @dev Starts the execution of a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeTokenTransferVote(uint256 communityId, uint256 index) external override {
        require(tokenTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = tokenTransferVotes[communityId][index];
        checkTransferVote(communityId, vote);

        if (vote.yesCount > vote.noCount) {
            executeTokenTransferVoteScript(communityId, uint256(vote.value), vote.wallet);
        }
        vote.active = false;

        emit ExecuteTokenTransferVote(_msgSender(), communityId, index);
    }

    /**
     * @dev Starts the execution of a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeNftTransferVote(uint256 communityId, uint256 index) external override {
        require(nftTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = nftTransferVotes[communityId][index];
        checkTransferVote(communityId, vote);

        if (vote.yesCount > vote.noCount) {
            executeNftTransferVoteScript(communityId, uint256(vote.value), vote.wallet);
        }
        vote.active = false;

        emit ExecuteNftTransferVote(_msgSender(), communityId, index);
    }

    /**
     * @dev Reading information about a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function readPrivacyAccessPriceVote(uint256 communityId, uint256 index) external override view returns(
        string memory description,
        address creator,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint128 newPrice,
        address[] memory voteUsers,
        bool active
    ) {
        require(privacyAccessPriceVotes[communityId].length > index, "PageVote: wrong index");

        UintValueVote storage vote = privacyAccessPriceVotes[communityId][index];

        description = vote.description;
        creator = vote.creator;
        finishTime = vote.finishTime;
        yesCount = vote.yesCount;
        noCount = vote.noCount;
        newPrice = vote.newPrice;
        voteUsers = vote.voteUsers.values();
        active = vote.active;
    }

    /**
     * @dev Reading information about a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function readTokenTransferVote(uint256 communityId, uint256 index) external override view returns(
        string memory,
        address,
        uint128,
        uint128,
        uint128,
        uint128,
        address,
        address[] memory,
        bool
    ) {
        require(tokenTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = tokenTransferVotes[communityId][index];

        return readTransferVote(communityId, vote);
    }

    /**
     * @dev Reading information about a Vote.
     *
     * @param communityId ID of community
     * @param index Voting number for the current community.
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function readNftTransferVote(uint256 communityId, uint256 index) external override view returns(
        string memory,
        address,
        uint128,
        uint128,
        uint128,
        uint128,
        address,
        address[] memory,
        bool
    ) {
        require(nftTransferVotes[communityId].length > index, "PageVote: wrong index");
        UintAddressValueVote storage vote = nftTransferVotes[communityId][index];

        return readTransferVote(communityId, vote);
    }

    function readTransferVote(uint256 communityId, UintAddressValueVote storage vote) private view returns (
        string memory description,
        address creator,
        uint128 finishTime,
        uint128 yesCount,
        uint128 noCount,
        uint128 amount,
        address wallet,
        address[] memory voteUsers,
        bool active
    ) {
        description = vote.description;
        creator = vote.creator;
        finishTime = vote.finishTime;
        yesCount = vote.yesCount;
        noCount = vote.noCount;
        amount = vote.value;
        wallet = vote.wallet;
        voteUsers = vote.voteUsers.values();
        active = vote.active;
    }

    /**
     * @dev Reading the amount of votes for the community.
     *
     * @param communityId ID of community
     */
    function readPrivacyAccessPriceVotesCount(uint256 communityId) public override view returns(uint256 count) {
        return privacyAccessPriceVotes[communityId].length;
    }

    /**
     * @dev Reading the amount of votes for the community.
     *
     * @param communityId ID of community
     */
    function readTokenTransferVotesCount(uint256 communityId) public override view returns(uint256 count) {
        return tokenTransferVotes[communityId].length;
    }

    function readNftTransferVotesCount(uint256 communityId) public override view returns(uint256 count) {
        return nftTransferVotes[communityId].length;
    }

    /**
     * @dev Starts the execution for change price.
     *
     * @param communityId ID of community
     * @param price Value of price
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executePrivacyAccessPriceVoteScript(uint256 communityId, uint256 price) private {
        bank.setPriceForPrivacyAccess(communityId, price);
    }

    /**
     * @dev Starts the execution for transfer PAGE tokens.
     *
     * @param communityId ID of community
     * @param amount Value for amount of tokens
     * @param wallet Address for transferring tokens
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeTokenTransferVoteScript(uint256 communityId, uint256 amount, address wallet) private {
        preventSameBlock(communityId);
        require(bank.transferFromCommunity(communityId, amount, wallet), "PageVote: wrong transfer");
    }

    /**
     * @dev Starts the execution for transfer NFT-post token.
     *
     * @param communityId ID of community
     * @param id Value for nft token id
     * @param wallet Address for transferring tokens
     * The total number of all votes is given by the "readVotesCount()" function.
     */
    function executeNftTransferVoteScript(uint256 communityId, uint256 id, address wallet) private {
        preventSameBlock(communityId);
        require(community.transferPost(communityId, id, wallet), "PageVote: wrong transfer");
    }

    function createTransferVote(
        UintAddressValueVote storage vote,
        string memory description,
        address sender,
        uint128 duration,
        uint128 value,
        address wallet
    ) private {
        vote.description = description;
        vote.creator = sender;
        vote.finishTime = uint128(block.timestamp) + duration;
        vote.value = value;
        vote.wallet = wallet;
        vote.active = true;
    }

    function putTransferVote(uint256 communityId, UintAddressValueVote storage vote, bool isYes) private returns(uint256) {
        address sender = _msgSender();

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
        lastVoteBlock[communityId] = block.number;

        return weight;
    }

    function checkTransferVote(uint256 communityId, UintAddressValueVote storage vote) private {
        address sender = _msgSender();
        require(community.isCommunityActiveUser(communityId, sender), "PageVote: access denied");
        require(vote.voteUsers.contains(sender), "PageVote: the user did not vote");
        require(vote.active, "PageVote: vote not active");
        require(vote.finishTime < block.timestamp, "PageVote: wrong time");
    }

    function preventSameBlock(uint256 communityId) private {
        require(block.number > lastVoteBlock[communityId], "PageVote: same block");
    }
}