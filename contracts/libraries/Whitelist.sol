// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

pragma solidity ^0.8.3;

contract Whitelist is OwnableUpgradeable {
    mapping(address => bool) private _whitelist;

    /// @notice Initial function
    function initialize() public initializer {
        __Ownable_init();
    }

    function setPermission(address account, bool permission) public onlyOwner {
        _whitelist[account] = permission;
    }
}
