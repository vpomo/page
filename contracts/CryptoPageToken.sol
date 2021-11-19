// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "./interfaces/IERCMINT.sol";
// import "./interfaces/ISAFE.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PageToken is ERC20("PageToken", "PAGE"), Ownable {
    // ISAFE private pageMinter;
    /* 
    constructor(ISAFE _pageMinter) ERC20("Crypto Page", "PAGE") {
        pageMinter = _pageMinter;
    }
    */
    // OPEN
    // function burn(uint256 amount) public override {
    // _burn(msg.sender, amount);
    // }

    // function withdraw(address to, uint256 amount) public {
    // require(isEnoughOn(msg.sender, amount), "Not enought balance");
    // _transfer(msg.sender, to, amount);
    // }
    /*
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
    */
    // ADMIN ONLY
    // modifier onlyAdmin() {
    // require(
    // msg.sender == address(pageMinter),
    // "onlyAdmin: caller is not the admin"
    // );
    // _;
    // }
    /*
    function mint(address to, uint256 amount) public override onlyAdmin {
        _mint(to, amount);
    }

    function burnFrom(address from, uint256 amount) public override onlyAdmin {
        _burn(from, amount);
    }
    */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyOwner {
        _burn(to, amount);
    }
    /*
    function burnFrom(address from, uint256 amount) override public onlyOwner {
        _burn(from, amount);
    }
    */
}
