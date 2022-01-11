// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageComment.sol";

/// @title Contract for storage and interaction of comments for ERC721 tokens
/// @author Crypto.Page Team
/// @notice Contract designed to store comments of one specific token
/// @dev These contracts are deployed by the `CryptoPageCommentDeployer` contract
contract PageComment {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    constructor(
        address _nft,
        uint256 _tokenId,
        address _bank
    ) {
        nft = IPageNFT(_nft);
        tokenId = _tokenId;
        bank = IPageBank(_bank);
    }

    struct Comment {
        uint256 id;
        address author;
        bytes32 ipfsHash; //This MUST be an base58 decoded hash. The reason of it is an IPFS hash consumes 46 bytes, which can't be stored at a single 32 bytes slot
        bool like;
        uint256 price;
    }

    IPageNFT public nft;
    IPageBank public bank;

    uint256 public tokenId;

    /// Stores all comments ids
    uint256[] public commentsIdsArray;
    /// Stores the Сomment struct by id
    mapping(uint256 => Comment) public commentsById;
    /// Stores the comment ids by author's address
    mapping(address => uint256[]) public commentsOf;

    CountersUpgradeable.Counter private _totalLikes;

    /// @notice The event is emmited when creating a new comment
    /// @dev Emmited occurs in the _createComment function
    /// @param id Comment id
    /// @param author Commenth author
    /// @param ipfsHash Comment text
    /// @param like Comment reaction (like or dislike)
    /// @param price Price in PAGE tokens
    event NewComment(
        uint256 id,
        address author,
        bytes32 ipfsHash, // This MUST be an base58 decoded hash. The reason of it is an IPFS hash consumes 46 bytes, which can't be stored at a single 32 bytes slot
        bool like,
        uint256 price
    );

    /*
    /// @notice Set price for comment by id
    /// @param id Comment id
    /// @param price Comment price in PAGE tokens
    // function setPrice(uint256 id, uint256 price) internal {
    // commentsById[id].price = price;
    // }
    
    /// @notice Internal function for creating comment with author param
    /// @param author Address of comment's author
    /// @param ipfsHash IPFS hash
    /// @param like Positive or negative reaction to comment
    
    function setComment(
        address author,
        bytes32 ipfsHash,
        bool like
    ) public returns (uint256) {
        return _createComment(author, ipfsHash, like, 0);
    }
    */

    /// @notice Create comment for any ERC721 Token
    /// @param _author Author of comment
    /// @param _ipfsHash IPFS hash
    /// @param _like Positive or negative reaction to comment
    // @param _price Price in PAGE tokens
    function _createComment(
        address _author,
        bytes32 _ipfsHash,
        bool _like
    )
        internal
        returns (
            // uint256 _price
            uint256
        )
    {
        uint256 id = commentsIdsArray.length;
        commentsIdsArray.push(id);
        commentsById[id] = Comment(id, _author, _ipfsHash, _like, 0);
        commentsOf[msg.sender].push(id);

        if (_like) {
            _totalLikes.increment();
        }

        emit NewComment(id, _author, _ipfsHash, _like, 0);

        return id;
    }

    /// @notice Create comment for any ERC721 Token
    /// @param ipfsHash IPFS hash
    /// @param like Positive or negative reaction to comment
    function createComment(bytes32 ipfsHash, bool like)
        public
        returns (uint256)
    {
        uint256 gasBefore = gasleft();
        require(msg.sender != address(0), "Address can't be null");
        uint256 id = _createComment(msg.sender, ipfsHash, like);
        uint256 gas = gasBefore - gasleft();
        // uint256 price = bank.calculateMint(
        commentsById[id].price = bank.calculateMint(
            msg.sender,
            IPageNFT(nft).ownerOf(id),
            gas
        );

        // return _createComment(msg.sender, ipfsHash, like, 0);
        return id;
    }

    /// @notice Return id's of all comments
    /// @return Array of Comment structs
    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIdsArray;
    }

    /// @notice Return comments by id's
    /// @return Array of Comment structs
    function getCommentsByIds(uint256[] memory ids)
        public
        view
        returns (Comment[] memory)
    {
        require(ids.length > 0, "ids length must be more than zero");
        require(
            ids.length <= commentsIdsArray.length,
            "ids length must be less or equal commentsIdsArray"
        );

        Comment[] memory comments = new Comment[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            require(
                ids[i] <= commentsIdsArray.length,
                "No comment with this ID"
            );
            Comment storage comment = commentsById[ids[i]];
            comments[i] = comment;
        }
        return comments;
    }

    /// @notice Return all comments
    /// @return Array of Comment structs
    function getComments() public view returns (Comment[] memory) {
        Comment[] memory comments;
        if (commentsIdsArray.length > 0) {
            comments = getCommentsByIds(commentsIdsArray);
        }
        return comments;
    }

    /// @notice Return comment by id
    /// @return Comment struct
    function getCommentById(uint256 id) public view returns (Comment memory) {
        require(id < commentsIdsArray.length, "No comment with this ID");
        return commentsById[id];
    }

    /// @notice Return statistic
    /// @return total Count of comments
    /// @return likes Count of likes
    /// @return dislikes Count of dislikes
    function getStatistic()
        public
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        )
    {
        total = commentsIdsArray.length;
        likes = _totalLikes.current();
        dislikes = total.sub(likes);
    }

    /// @notice Return statistic with comments
    /// @return total Count of comments
    /// @return likes Count of likes
    /// @return dislikes Count of dislikes
    /// @return comments Array of Comment structs
    function getStatisticWithComments()
        public
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes,
            Comment[] memory comments
        )
    {
        (uint256 _total, uint256 _likes, uint256 _dislikes) = getStatistic();
        total = _total;
        likes = _likes;
        dislikes = _dislikes;
        comments = getComments();
    }

    /// @notice Return comments by author's address
    /// @param author Address of author
    /// @return Comments Array of Comment structs
    function getCommentsOf(address author)
        public
        view
        returns (Comment[] memory)
    {
        require(msg.sender != address(0), "Address can't be null");
        uint256[] memory ids = commentsOf[author];
        Comment[] memory comments;
        if (ids.length > 0) {
            comments = getCommentsByIds(ids);
        }
        return comments;
    }
}
