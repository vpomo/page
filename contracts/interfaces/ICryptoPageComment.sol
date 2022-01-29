// SPDX-License-Identifier: MIT

pragma solidity 0.8.1;

interface IPageComment {
    struct Comment {
        uint256 id;
        address author;
        bytes32 ipfsHash;
        bool like;
        uint256 price;
    }

    event NewComment(
        uint256 id,
        address author,
        bytes32 ipfsHash,
        bool like,
        uint256 price
    );

    function createComment(
        address nft,
        uint256 tokenId,
        bytes32 ipfsHash,
        bool like
    ) external returns (Comment memory comment);

    function getCommentsIds(address nft, uint256 tokenId)
        external
        view
        returns (uint256[] memory);

    function getCommentsByIds(
        address nft,
        uint256 tokenId,
        uint256[] memory ids
    ) external view returns (Comment[] memory comments);

    function getComments(address nft, uint256 tokenId)
        external
        view
        returns (Comment[] memory comments);

    function getCommentById(
        address nft,
        uint256 tokenId,
        uint256 id
    ) external view returns (Comment memory comment);

    function getStatistic(address nft, uint256 tokenId)
        external
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes
        );

    function getStatisticWithComments(address nft, uint256 tokenId)
        external
        view
        returns (
            uint256 total,
            uint256 likes,
            uint256 dislikes,
            Comment[] memory comments
        );

    function calculateCommentsReward(address nft, uint256 tokenId)
        external
        returns (uint256 reward);
}
