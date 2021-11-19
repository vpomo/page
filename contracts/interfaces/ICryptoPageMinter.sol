// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IPageComment {
    function mint(address _to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

    function setBurnNFTCost(uint256 _cost) external;

    function setTreasuryFee(uint256 _percent) external;

    function setTreasuryAddress(address _treasuryAddress) external;

    function getBurnNFTCost() external;

    function getAdmin() external;

    function getPageToken() external;
}
