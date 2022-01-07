// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface IPageBank {
    function mint(address to, uint256 gas) external payable returns (uint256);

    function mintFor(
        address from,
        address to,
        uint256 gas
    ) external payable returns (uint256);

    function burn(
        address to,
        uint256 gas,
        uint256 burnPrice
    ) external payable;

    function transferFrom(
        address from,
        address to,
        uint256 gas
    ) external payable;

    function comment(
        address from,
        address to,
        uint256 gas
    ) external payable returns (uint256);

    function getWETHUSDTPrice() external view returns (uint256);

    function getUSDTPAGEPrice() external view returns (uint256);

    // function setUSDTPAGEPool(address _usdtpagePool) external;

    // function setWETHUSDTPool(address _wethusdtPool) external;
}
