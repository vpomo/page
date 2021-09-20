// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/INFTMINT.sol";
import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

contract PageNFTBank {
    INFTMINT public PAGE_NFT;
    IMINTER public PAGE_MINTER;
    IERCMINT public PAGE_TOKEN;
    constructor (address _PAGE_NFT, address _PAGE_MINTER) {
        PAGE_NFT = INFTMINT(_PAGE_NFT);
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
        PAGE_TOKEN = IERCMINT(PAGE_MINTER.getPageToken());
    }

    function Buy(uint256 _amount) public {
        require(PAGE_TOKEN.isEnoughOn(msg.sender, _amount), "Not enough tokens");
        PAGE_TOKEN.safeDeposit(msg.sender, address(this), _amount);
    }
    function Sell(uint256) public {
        // MINT
    }

    modifier onlyAdmin() {        
        require(msg.sender == PAGE_MINTER.getAdmin(), "onlyAdmin: caller is not the admin");
        _;
    }

    uint256 private _sell;
    uint256 private _buy;
    function setBuyPrice(uint256) public onlyAdmin() {
        
    }
    function setSellPrice(uint256) public onlyAdmin() {
        
    }
    function getPrice() public view returns(uint256 sell, uint256 buy ) {
        sell = _sell;
        buy = _buy;
    }
    
}
