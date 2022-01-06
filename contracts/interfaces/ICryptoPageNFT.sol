// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721MetadataUpgradeable.sol";

interface IPageNFT is IERC721MetadataUpgradeable {
    function safeMint(address _owner, string memory _tokenURI)
        external
        returns (uint256);

    function safeBurn(uint256 _tokenId) external;

    // function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function tokenPrice(uint256 tokenId) external view returns (uint256);
}
