// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IPageCommentDeployer {
    function initialize() external payable;

    function isExists(address nft, uint256 tokenId)
        external
        view
        returns (bool);

    /*
    function createComment(
        address nft,
        uint256 tokenId,
        // address author,
        bytes32 ipfsHash,
        bool like
    ) external;
    */
    function getCommentContract(address nft, uint256 tokenId)
        external
        view
        returns (address);

    function deploy(address nft, uint256 tokenId)
        external
        payable
        returns (address);
}
