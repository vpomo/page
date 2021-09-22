
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IERCMINT.sol";
import './interfaces/ISAFE.sol';

contract PageToken is ERC20, IERCMINT {

    ISAFE private PAGE_MINTER;
    constructor(address _PAGE_MINTER) ERC20("Crypto Page", "PAGE") {
        // address _IMINTER
        PAGE_MINTER = ISAFE(_PAGE_MINTER);
    }

    // OPEN
    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
    }

    function isEnoughOn(address account, uint256 amount) public override view returns (bool) {
        if (balanceOf(account) >= amount) {
            return true;
        } else {
            return false;
        }
    }

    // ADMIN ONLY
    modifier onlyAdmin() {        
        require(msg.sender == address(PAGE_MINTER), "onlyAdmin: caller is not the admin");
        _;
    }
    function mint(address to, uint256 amount) public onlyAdmin() override {
        _mint(to, amount);
    }
    function xburn(address from, uint256 amount) public onlyAdmin() override{
        _burn(from, amount);
    }
    
    modifier onlySafe() {        
        require(PAGE_MINTER.isSafe(msg.sender), "onlySafe: caller is not in safe list");
        _;
    }

    // ISAFE
    function safeDeposit(address from, address to, uint256 amount) public override onlySafe() {
        _transfer(from, to, amount);
    }
    function safeWithdraw(address from, address to, uint256 amount) public override onlySafe() {
        _transfer(from, to, amount);
    }
}