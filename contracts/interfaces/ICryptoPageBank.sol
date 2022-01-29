// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

interface IPageBank {
    function calculateMint(
        address sender,
        address receiver,
        uint256 gas
    ) external returns (uint256 amount);

    function calculateBurn(
        address receiver,
        uint256 gas,
        uint256 commentsReward
    ) external returns (uint256 amount);

    function getWETHUSDTPrice() external view returns (uint256);

    function getUSDTPAGEPrice() external view returns (uint256);

    function setUSDTPAGEPool(address _usdtpagePool) external;

    function setWETHUSDTPool(address _wethusdtPool) external;

    function setToken(address _address) external;

    function withdraw(uint256 amount) external;

    function balance() external view returns (uint256);
}
