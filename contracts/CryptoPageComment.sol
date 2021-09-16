// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract PageComment is Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;

    // NEW COMMENTS
    struct Comment {
        uint256 uid;
        address author;
        string text;
        bool like;
    }
    event NewComment(
        uint256 uid,
        address author,
        string text,
        bool like
    );
    mapping(uint256 => Comment) public commentsById;
    mapping(address => EnumerableSet.UintSet) private commentsIdsOf;
    function _comment(string memory text, bool like, address user) public onlyOwner {
        uint256 uid = _totalComments.current();
        commentsIdsOf[user].add(uid);
        commentsById[uid] = Comment({
            uid: uid,
            author: user,
            text: text,
            like: like
        });
        emit NewComment(
            uid,
            user,
            text,
            like);
        _increment(like);
    }

    // STATISTICS
    Counters.Counter private _totalComments;
    Counters.Counter private _totalLikes;
    Counters.Counter private _totalDislakes;
    function totalStats() public view returns (uint256 Comments, uint256 Likes, uint256 Dislakes)
    {
        Comments = _totalComments.current();
        Likes = _totalLikes.current();
        Dislakes = _totalDislakes.current();
    }
    function _increment(bool like) private {
        if (like) {
            _totalLikes.increment();
        } else {
            _totalDislakes.increment();
        }
        _totalComments.increment();
    }
}


