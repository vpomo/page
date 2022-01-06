// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

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

    function setPrice(uint256 id, uint256 price) external;

    function setComment(
        address author,
        string memory text,
        bool like
    ) external returns (uint256);

    function createComment(
        address author,
        string memory text,
        bool like
    ) external returns (uint256);

    function getCommentsIds() external view returns (uint256[] memory);

    function getCommentsByIds(uint256[] memory _ids)
        external
        view
        returns (Comment[] memory);

    function getComments() external view returns (Comment[] memory);

    function getCommentById(uint256 id) external view returns (Comment memory);

    function getStatistic()
        external
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        );

    function getStatisticWithComments()
        external
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes,
            Comment[] memory comments
        );
}
