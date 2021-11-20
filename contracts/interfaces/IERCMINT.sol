// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERCMINT {
    function mint(address to, uint256 amount) external;

    function burnFrom(address from, uint256 amount) external;

    function burn(uint256 amount) external;

    function isEnoughOn(address account, uint256 amount)
        external
        view
        returns (bool);
}
