// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockUSDTToken is ERC20("MockToken", "MOCK") {
    constructor() {
        _mint(address(this), 1000 * 10**18);
        _mint(msg.sender, 1000 * 10**18);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
