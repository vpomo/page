// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IPageCommentDeployer {
    function initialize(address _bank) external payable;

    function isExists(address nft, uint256 tokenId)
        external
        view
        returns (bool);

    function createComment(
        address nft,
        uint256 tokenId,
        address author,
        string memory text,
        bool like
    ) external;

    function getCommentContract(address nft, uint256 tokenId)
        external
        view
        returns (address);
}
