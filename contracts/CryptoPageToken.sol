// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IERCMINT.sol";
import "./interfaces/ISAFE.sol";

// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PageToken is ERC20, IERCMINT {
    ISAFE private pageMinter;

    constructor(address _pageMinter) ERC20("Crypto Page", "PAGE") {
        pageMinter = ISAFE(_pageMinter);
    }

    // OPEN
    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
    }

    function isEnoughOn(address account, uint256 amount)
        public
        view
        override
        returns (bool)
    {
        if (balanceOf(account) >= amount) {
            return true;
        } else {
            return false;
        }
    }

    // ADMIN ONLY
    modifier onlyAdmin() {
        require(
            msg.sender == address(pageMinter),
            "onlyAdmin: caller is not the admin"
        );
        _;
    }

    function mint(address to, uint256 amount) public override onlyAdmin {
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) public override onlyAdmin {
        _burn(from, amount);
    }

    modifier onlySafe() {
        require(
            pageMinter.isSafe(msg.sender),
            "onlySafe: caller is not in safe list"
        );
        _;
    }

    // ISAFE
    /*
    function safeDeposit(
        address from,
        address to,
        uint256 amount
    ) public override onlySafe {
        _transfer(from, to, amount);
    }
    */

    function safeWithdraw(
        address from,
        address to,
        uint256 amount
    ) public override onlySafe {
        _transfer(from, to, amount);
    }
}
