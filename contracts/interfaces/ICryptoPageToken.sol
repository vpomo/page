// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IPageToken is IERC20Upgradeable {
    function mint(address to, uint256 amount) external;

    function burn(address to, uint256 amount) external;
}
