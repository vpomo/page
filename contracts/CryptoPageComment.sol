// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./interfaces/ICryptoPageComment.sol";

/// @title Contract for storage and interaction of comments for ERC721 tokens
/// @author Crypto.Page Team
/// @notice Contract designed to store comments of one specific token
/// @dev These contracts are deployed by the `CryptoPageCommentDeployer` contract
contract PageComment {
    using SafeMathUpgradeable for uint256;
    using CountersUpgradeable for CountersUpgradeable.Counter;

    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
        uint256 price;
    }

    /// Stores all comments ids
    uint256[] public commentsIds;
    /// Stores the Сomment struct by id
    mapping(uint256 => Comment) public commentsById;
    /// Stores the comment ids by author's address
    mapping(address => uint256[]) public commentsOf;

    CountersUpgradeable.Counter private _totalLikes;

    /// @notice The event is emmited when creating a new comment
    /// @dev Emmited occurs in the _createComment function
    /// @param id Comment id
    /// @param author Commenth author
    /// @param text Comment text
    /// @param like Comment reaction (like or dislike)
    /// @param price Price in PAGE tokens
    event NewComment(
        uint256 id,
        address author,
        string text,
        bool like,
        uint256 price
    );

    /// @notice Set price for comment by id
    /// @param id Comment id
    /// @param price Comment price in PAGE tokens
    function setPrice(uint256 id, uint256 price) internal {
        commentsById[id].price = price;
    }

    /// @notice Internal function for creating comment with author param
    /// @param author Address of comment's author
    /// @param text Comment text
    /// @param like Positive or negative reaction to comment
    function setComment(
        address author,
        string memory text,
        bool like
    ) internal returns (uint256) {
        return _createComment(author, text, like, 0);
    }

    /// @notice Create comment for any ERC721 Token
    /// @param _author Author of comment
    /// @param _text Text of comment
    /// @param _like Positive or negative reaction to comment
    /// @param _price Price in PAGE tokens
    function _createComment(
        address _author,
        string memory _text,
        bool _like,
        uint256 _price
    ) internal returns (uint256) {
        uint256 id = commentsIds.length;
        commentsIds.push(id);
        commentsById[id] = Comment(id, _author, _text, _like, _price);
        commentsOf[msg.sender].push(id);

        if (_like) {
            _totalLikes.increment();
        }

        emit NewComment(id, _author, _text, _like, _price);

        return id;
    }

    /// @notice Create comment for any ERC721 Token
    /// @param text Text of comment
    /// @param like Positive or negative reaction to comment
    function createComment(string memory text, bool like)
        public
        returns (uint256)
    {
        require(msg.sender != address(0), "Address can't be null");
        return _createComment(msg.sender, text, like, 0);
    }

    /// @notice Return id's of all comments
    /// @return Array of Comment structs
    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIds;
    }

    /// @notice Return comments by id's
    /// @return Array of Comment structs
    function getCommentsByIds(uint256[] memory _ids)
        public
        view
        returns (Comment[] memory)
    {
        require(_ids.length > 0, "_ids length must be more than zero");
        require(
            _ids.length <= commentsIds.length,
            "_ids length must be less or equal commentsIds"
        );

        Comment[] memory comments = new Comment[](_ids.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            require(_ids[i] <= commentsIds.length, "No comment with this ID");
            Comment storage comment = commentsById[_ids[i]];
            comments[i] = comment;
        }
        return comments;
    }

    /// @notice Return all comments
    /// @return Array of Comment structs
    function getComments() public view returns (Comment[] memory) {
        Comment[] memory comments;
        if (commentsIds.length > 0) {
            comments = getCommentsByIds(commentsIds);
        }
        return comments;
    }

    /// @notice Return comment by id
    /// @return Comment struct
    function getCommentById(uint256 id) public view returns (Comment memory) {
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
        total = commentsIds.length;
        likes = _totalLikes.current();
        dislikes = total - likes;
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
