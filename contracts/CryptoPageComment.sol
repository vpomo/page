// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./interfaces/ICryptoPageComment.sol";

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

    uint256[] public commentsIds;

    mapping(uint256 => Comment) public commentsById;

    CountersUpgradeable.Counter private _totalLikes;

    event NewComment(
        uint256 id,
        address author,
        string text,
        bool like,
        uint256 price
    );

    function setPrice(uint256 id, uint256 price) internal {
        commentsById[id].price = price;
    }

    function setComment(
        address author,
        string memory text,
        bool like
    ) internal returns (uint256) {
        return _createComment(author, text, like, 0);
    }

    /// @notice Create comment for any ERC721 Token
    /// @param author Author of comment
    /// @param text Text of comment
    /// @param like Positive or negative reaction to comment
    function _createComment(
        address author,
        string memory text,
        bool like,
        uint256 price
    ) internal returns (uint256) {
        uint256 id = commentsIds.length;

        commentsIds.push(id);
        commentsById[id] = Comment(id, author, text, like, price);

        if (like) {
            _totalLikes.increment();
        }

        emit NewComment(id, author, text, like, price);

        return id;
    }

    /// @notice Create comment for any ERC721 Token
    /// @param text Text of comment
    /// @param like Positive or negative reaction to comment
    function createComment(string memory text, bool like)
        public
        returns (uint256)
    {
        return _createComment(msg.sender, text, like, 0);
    }

    /// @notice Return id's of all comments
    /// @return comments Array of Comment structs
    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIds;
    }

    /// @notice Return comments by id's
    /// @return comments Array of Comment structs
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
    /// @return comments Array of Comment structs
    function getComments() public view returns (Comment[] memory) {
        Comment[] memory comments;
        if (commentsIds.length > 0) {
            comments = getCommentsByIds(commentsIds);
        }
        return comments;
    }

    /// @notice Return comment by id
    /// @return Comment Count of dislikes
    function getCommentById(uint256 id) public view returns (Comment memory) {
        // require(id <= commentsIds.length, "No comment with this ID");
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
}
