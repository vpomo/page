// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IPageComment {
    struct Comment {
        uint256 id;
        address author;
        string text;
        bool like;
        uint256 price;
    }

    event NewComment(
        uint256 id,
        address author,
        string text,
        bool like,
        uint256 price
    );

    function getActive() external returns (bool);

    function createComment(
        address author,
        string memory text,
        bool like
    ) external returns (uint256);

    function getCommentsIds() external returns (uint256[] memory);

    function getCommentsByIds(uint256[] memory _ids)
        external
        returns (Comment[] memory);

    function getComments() external returns (Comment[] memory);

    function getCommentById(uint256 id)
        external
        returns (
            uint256,
            address,
            string memory,
            bool
        );

    function getStatistic()
        external
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        );

    function toggleActive() external;

    function _incrementStatistic(bool like) external;
}
