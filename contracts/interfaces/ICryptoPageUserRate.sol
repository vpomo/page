// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Upgradeable.sol";

interface IPageUserRate is IERC1155Upgradeable {

    function version() external pure returns (string memory);

    function setCommunity(address communityContract) external;

    function setBaseTokenURI(string memory baseTokenURI) external;

    function mint(address owner) external returns (uint256);

    function burn(uint256 tokenId) external;

    function tokensOfOwner(address user) external view returns (uint256[] memory);

}
