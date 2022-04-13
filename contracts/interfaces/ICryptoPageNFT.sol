// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";

interface IPageNFT is IERC721EnumerableUpgradeable {

    function version() external pure returns (string memory);

    function setCommunity(address communityContract) external;

    function setBaseTokenURI(string memory baseTokenURI) external;

    function mint(address owner) external returns (uint256);

    function burn(uint256 tokenId) external;

    function tokensOfOwner(address user) external view returns (uint256[] memory);

}
