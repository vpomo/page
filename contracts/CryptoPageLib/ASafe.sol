// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import './Admin.sol';

abstract contract ASafe is Admin {
    // SAFE LIST
    mapping(address => bool) private safeList;
    function addSafe( address _safe ) public onlyOwner() {        
        safeList[_safe] = true;
    }
    function removeSafe( address _safe ) public onlyOwner() {
        safeList[_safe] = false;        
    }
    function changeSafe( address _from, address _to ) public onlyOwner() {
        safeList[_from] = false;
        safeList[_to] = true;       
    }
    function isSafe( address _check ) public view returns (bool) {
        return safeList[_check];  
    }
    modifier onlySafe() {        
        require(isSafe(msg.sender), "onlySafe: caller is not in safe list");
        _;
    }
}