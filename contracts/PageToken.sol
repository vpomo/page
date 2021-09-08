
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./CryptoPageMinter.sol";

contract CryptoPageToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    PageMinter public PAGE_MINTER;
    constructor() ERC20("Crypto Page", "PAGE") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        PAGE_MINTER = new PageMinter(address(this),msg.sender,msg.sender);
        _setupRole(MINTER_ROLE, address(PAGE_MINTER));
    }
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
    function setMinter(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER_ROLE, _minter);
    }
}