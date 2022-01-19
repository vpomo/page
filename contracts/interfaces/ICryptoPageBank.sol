// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IPageBank {
    function calculateMint(
        address sender,
        address receiver,
        uint256 amount
    ) external returns (uint256);

    function calculateBurn(
        address receiver,
        uint256 gas,
        uint256 commentsReward
    ) external returns (uint256);

    function getWETHUSDTPrice() external view returns (uint256);

    function getUSDTPAGEPrice() external view returns (uint256);

    function setUSDTPAGEPool(address _usdtpagePool) external;

    function setWETHUSDTPool(address _wethusdtPool) external;

    function setToken(address _address) external;

    function withdraw(uint256 amount) external payable;

    function balanceOf() external view returns (uint256);
}
