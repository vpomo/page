// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract Admin {
    address public owner;
    constructor (address _owner) {
        owner = _owner;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner() {
        address oldOwner = owner;
        require(newOwner != oldOwner, "changeOwner: the owner must be different from the current one");
        require(newOwner != address(0), "changeOwner: owner need to be different from zero address");
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function renounceOwnership() public onlyOwner() {
        address oldOwner = owner;
        owner = address(0);
        emit OwnershipRenounced(oldOwner);
    }
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRenounced(address indexed previousOwner);
}
