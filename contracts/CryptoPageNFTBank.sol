// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IERCMINT.sol";
import "./interfaces/IMINTER.sol";

// import './CryptoPageMinter.sol';
contract PageNFTBank {
    IERCMINT public PAGE_TOKEN;
    IMINTER public PAGE_MINTER;
    constructor (address _PAGE_TOKEN, address _PAGE_MINTER) {
        PAGE_TOKEN = IERCMINT(_PAGE_TOKEN);
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
    }
}
