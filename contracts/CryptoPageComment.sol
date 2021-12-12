// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PageComment {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;

    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
        uint256 price;
    }

    uint256[] public commentsIds;

    mapping(uint256 => Comment) public commentsById;

    Counters.Counter private _totalLikes;
    Counters.Counter private _totalDislikes;

    event NewComment(
        uint256 id,
        address author,
        string text,
        bool like,
        uint256 price
    );

    function createComment(
        address author,
        string memory text,
        bool like
    ) public returns (uint256) {
        uint256 amount = gasleft().mul(tx.gasprice);
        uint256 id = commentsIds.length;

        commentsIds.push(id);
        commentsById[id] = Comment(id, author, text, like, 0);
        commentsById[id].price = amount;

        if (like) {
            _totalLikes.increment();
        } else {
            _totalDislikes.increment();
        }

        emit NewComment(id, author, text, like, amount);

        return id;
    }

    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIds;
    }

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

    function getComments() public view returns (Comment[] memory) {
        Comment[] memory comments;
        if (commentsIds.length > 0) {
            comments = getCommentsByIds(commentsIds);
        }
        return comments;
    }

    function getCommentById(uint256 id) public view returns (Comment memory) {
        require(id <= commentsIds.length, "No comment with this ID");
        return commentsById[id];
    }

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
        dislikes = _totalDislikes.current();
    }

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
        total = commentsIds.length;
        likes = _totalLikes.current();
        dislikes = _totalDislikes.current();
        comments = getComments();
    }
}
