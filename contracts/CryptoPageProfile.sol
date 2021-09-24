// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PageProfile {
    using EnumerableSet for EnumerableSet.UintSet;
    using Counters for Counters.Counter;
    IMINTER public PAGE_MINTER;
    constructor (address _PAGE_MINTER) {
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
    }

    // COMMENTS
    Counters.Counter private _totalSocial;

    // +
    //ADD SOCIALS
    struct Social {
        uint256 uid;
        address author;
        string title;
        string url;
    }
    mapping(uint256 => Social) public SocialById;
    mapping(address => EnumerableSet.UintSet) private SocialIdsOf;
    function _add_social(string memory title, string memory url) public {
        uint256 uid = _totalSocial.current();
        address user = msg.sender;
        SocialIdsOf[user].add(uid);
        SocialById[uid] = Social({
            uid: uid,
            author: user,
            title: title,
            url: url
        });
    }

    //ADD STATUS
}
