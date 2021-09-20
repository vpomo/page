// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

contract PageProfile {
    IMINTER public PAGE_MINTER;
    constructor (address _PAGE_MINTER) {
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
    }
}
