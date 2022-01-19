// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

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
    ) external returns (uint256);

    function getCommentsIds(address nft, uint256 tokenId)
        external
        view
        returns (uint256[] memory);

    function getCommentsByIds(
        address nft,
        uint256 tokenId,
        uint256[] memory ids
    ) external view returns (Comment[] memory);

    function getComments(address nft, uint256 tokenId)
        external
        view
        returns (Comment[] memory);

    function getCommentById(
        address nft,
        uint256 tokenId,
        uint256 id
    ) external view returns (Comment memory);

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
}
