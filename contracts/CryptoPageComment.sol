// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PageComment is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;

    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
    }

    bool private active = true;
    uint256[] public commentsIds;

    mapping(uint256 => Comment) public commentsById;

    Counters.Counter private _totalLikes;
    Counters.Counter private _totalDislikes;

    event NewComment(uint256 id, address author, string text, bool like);

    modifier onlyActive() {
        require(active, "Comments not activated.");
        _;
    }

    constructor(address _owner) {
        transferOwnership(_owner);
    }

    function getActive() public view returns (bool) {
        return active;
    }

    function createComment(
        address author,
        string memory text,
        bool like
    ) public onlyActive {
        uint256 id = commentsIds.length;
        commentsIds.push(id);
        commentsById[id] = Comment(id, author, text, like);

        emit NewComment(id, author, text, like);

        _incrementStatistic(like);
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

    function toggleActive() public onlyOwner {
        if (active) {
            active = false;
        } else {
            active = true;
        }
    }

    function _incrementStatistic(bool like) private {
        if (like) {
            _totalLikes.increment();
        } else {
            _totalDislikes.increment();
        }
    }
}
