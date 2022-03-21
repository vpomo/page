// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/access/AccessControlUpgradeable.sol";

import "./interfaces/ICryptoPageBank.sol";
import "./interfaces/ICryptoPageToken.sol";

contract CryptoPageVote is
    Initializable,
    OwnableUpgradeable,
    AccessControlUpgradeable
{

    bytes32 public constant UPDATER_FEE_ROLE = keccak256("UPDATER_FEE_ROLE");

    function initialize(address _admin) public initializer {
        __Ownable_init();
        require(_admin != address(0), "PageBank: wrong address");
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setRoleAdmin(UPDATER_FEE_ROLE, DEFAULT_ADMIN_ROLE);
    }

}
