// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PageComment is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;

    // NEW COMMENTS
    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
    }
    event NewComment(uint256 id, address author, string text, bool like);
    mapping(uint256 => Comment) public commentsById;
    mapping(address => EnumerableSet.UintSet) private commentsIdsOf;
    uint256[] public commentsIds;
    Counters.Counter private _totalLikes;
    Counters.Counter private _totalDislikes;

    function createComment(
        address author,
        string memory text,
        bool like
    ) public onlyOwner {
        uint256 id = commentsIds.length;
        commentsIdsOf[author].add(id);
        commentsIds.push(id);
        commentsById[id] = Comment(id, author, text, like);

        emit NewComment(id, author, text, like);

        _incrementTotalStats(like);
    }

    function getCommentsIds() public view returns (uint256[] memory) {
        return commentsIds;
    }

    function getCommentsByIds(uint256[] memory _ids)
        public
        view
        returns (
            uint256[] memory,
            address[] memory,
            string[] memory,
            bool[] memory
        )
    {
        require(_ids.length > 0, "_ids length must be more than zero");
        require(
            _ids.length <= commentsIds.length,
            "_ids length must be less or equal commentsIds"
        );
        uint256[] memory ids = new uint256[](_ids.length);
        address[] memory authors = new address[](_ids.length);
        string[] memory texts = new string[](_ids.length);
        bool[] memory likes = new bool[](_ids.length);

        for (uint256 i = 0; i < ids.length; i++) {
            require(_ids[i] <= commentsIds.length, "No comment with this ID");
            Comment storage comment = commentsById[_ids[i]];
            ids[i] = comment.id;
            authors[i] = comment.author;
            texts[i] = comment.text;
            likes[i] = comment.like;
        }
        return (ids, authors, texts, likes);
    }

    function getComments()
        public
        view
        returns (
            uint256[] memory,
            address[] memory,
            string[] memory,
            bool[] memory
        )
    {
        return getCommentsByIds(commentsIds);
    }

    function getCommentById(uint256 id)
        public
        view
        returns (
            uint256,
            address,
            string memory,
            bool
        )
    {
        require(id <= commentsIds.length, "No comment with this ID");
        return (
            commentsById[id].id,
            commentsById[id].author,
            commentsById[id].text,
            commentsById[id].like
        );
    }

    function totalStats()
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

    function _incrementTotalStats(bool like) private {
        if (like) {
            _totalLikes.increment();
        } else {
            _totalDislikes.increment();
        }
    }
}
