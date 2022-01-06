// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IPageCommentDeployer {
    function initialize(address _token, address _bank) external payable;

    function _exists(address _nft, uint256 _tokenId)
        external
        view
        returns (bool);

    function _get(address _nft, uint256 _tokenId)
        external
        view
        returns (address);

    function _set(address _nft, uint256 _tokenId) external returns (address);

    function isExists(address _nft, uint256 _tokenId)
        external
        view
        returns (bool);

    function createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) external;

    function _createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) external returns (uint256);

    function getCommentContract(address _nft, uint256 _tokenId)
        external
        view
        returns (address);
}
