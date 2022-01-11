// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockToken is ERC20("MockToken", "MOCK") {
    uint8 private _decimals;

    constructor(uint8 __decimals) {
        _mint(address(this), 1000 * 10**18);
        _mint(msg.sender, 1000 * 10**18);
        _decimals = __decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
