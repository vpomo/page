// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IMINTER {
    function mint(address _to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function setBurnNFTCost(uint256 _cost) external;

    function getBurnNFTCost() external view returns (uint256);

    function getAdmin() external view returns (address);

    function getPageToken() external view returns (address);
}
