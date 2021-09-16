
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
// import "./CryptoPageMinter.sol";
// import "./CryptoPageNFT.sol";

import '@openzeppelin/contracts/access/Ownable.sol';

import "./interfaces/IERCMINT.sol";
// import "./interfaces/IMINTER.sol";
// import './interfaces/ISAFE.sol';

contract CryptoPageToken is ERC20, AccessControl, IERCMINT {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // IMINTER public PAGE_MINTER;
    // ISAFE public PAGE_SAFE;

    // PageMinterNFT public PAGE_MINTER_NFT;
    constructor() ERC20("Crypto Page", "PAGE") {
        // PAGE_MINTER = new PageMinter(address(this),msg.sender,msg.sender);
        // PAGE_MINTER_NFT = new PageMinterNFT(address(PAGE_MINTER));
        // ISAFE
        // _setupRole(MINTER_ROLE, address(PAGE_MINTER));

        _setupRole(ADMIN_ROLE, msg.sender);
    }
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) override {
        _mint(to, amount);
    }
    function xburn(address from, uint256 amount) public onlyRole(MINTER_ROLE) override{
        _burn(from, amount);
    }
    function burn(uint256 amount) public override {
        _burn(msg.sender, amount);
    }

    /*
        function _transfer(
        address sender,
        address recipient,
        uint256 amount
    */
    // > > > onlyPageToken < < < 
    /*
    modifier onlyMinter() {
        require(msg.sender == AdminAddress, "onlyAdmin: caller is not the admin");
        _;
    }
    */
    function safeDeposit(address from, address to, uint256 amount) public override {
        // require(msg.sender == AdminAddress, "onlyAdmin: caller is not the admin");
        _transfer(from, to, amount);
    }
    function safeWithdraw(address from, address to, uint256 amount) public override {
        // require(msg.sender == AdminAddress, "onlyAdmin: caller is not the admin");
        _transfer(from, to, amount);
    }

}