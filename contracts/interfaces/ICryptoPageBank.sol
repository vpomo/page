// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";

interface IPageBank is IAccessControlUpgradeable {
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

    function setUSDTPAGEPool(address _usdtpagePool) external;

    function setWETHUSDTPool(address _wethusdtPool) external;

    function getWETHUSDTPrice() external view returns (uint256);

    function getUSDTPAGEPrice() external view returns (uint256);

    function _addBalance(address _to, uint256 _amount)
        external
        returns (uint256);

    function _subBalance(address _to, uint256 _amount)
        external
        returns (uint256);

    function _setBalance(address _to, uint256 _amount) external;

    function _calculateAmount(uint256 _gas) external view returns (uint256);
}
