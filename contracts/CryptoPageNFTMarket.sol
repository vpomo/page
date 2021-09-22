// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/INFTMINT.sol";
import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

contract PageNFTMarket {
    INFTMINT public PAGE_NFT;
    IMINTER public PAGE_MINTER; 
    IERCMINT public PAGE_TOKEN;
    constructor (address _PAGE_NFT, address _PAGE_MINTER) {
        PAGE_NFT = INFTMINT(_PAGE_NFT);
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
    }
    // DEPOSIT
}
