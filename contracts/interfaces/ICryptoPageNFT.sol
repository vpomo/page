// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IPageNFT is IERC721Upgradeable {
    function safeMint(
        address owner,
        string memory tokenURI,
        bytes32 collectionName
    ) external returns (uint256 tokenId);

    function safeBurn(uint256 tokenId) external;

    // function safeTransferFrom2(
        // address from,
        // address to,
        // uint256 tokenId
    // ) external;
    // function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    // function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function tokenPrice(uint256 tokenId) external returns (uint256);

    function getTokensIdsByCollectionName(
        address account,
        bytes32 collectionName
    ) external returns (uint256[] memory tokenIds);

    function getTokensURIsByCollectionName(
        address account,
        bytes32 collectionName
    ) external returns (string[] memory tokenURIs);

    function getCollectionsByAddress(address _address)
        external
        returns (bytes32[] memory collectionNames);
}
