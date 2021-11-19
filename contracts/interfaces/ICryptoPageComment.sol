// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPageComment {
    function createComment(
        address author,
        string memory text,
        bool like
    ) external;

    function getCommentsIds() external;

    function getCommentsByIds(uint256[] memory _ids) external;

    function getComments() external;

    function getCommentById(uint256 id) external;

    function getStatistic() external;

    function _incrementStatistic(bool like) external;
}
