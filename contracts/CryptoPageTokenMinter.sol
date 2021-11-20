// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./CryptoPageToken.sol";
import "./CryptoPageNFTMinter.sol";

contract PageTokenMinter is AccessControl, Ownable {
    using SafeMath for uint256;
    // using Counters for Counters.Counter;
    // using Roles for Roles.Role;
    address private treasury = address(0);
    address private admin = address(0);

    PageToken private token;
    PageNFTMinter private nftMinter;

    uint256 private mintFee = 1000; // 100 is 1% || 10000 is 100%
    uint256 private burnFee = 0; // 100 is 1% || 10000 is 100%

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(PageToken _token) {
        token = _token;
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
    }

    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        token.mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyRole(BURNER_ROLE) {
        token.burn(_from, _amount);
    }
}
