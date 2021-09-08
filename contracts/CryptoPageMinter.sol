
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./PageToken.sol";


import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PageMinter is AccessControl{
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter public minterCount;



    CryptoPageToken public PAGE;
    address public TreasuryAddress = address(0);
    uint256 public TreasuryFee = 1500; // 100 is 1% || 10000 is 100%

    constructor(address _page, address _treasury, address _admin) {   
        // setAdminRole
        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        TreasuryAddress = _treasury; // setTreasuryAddress
        PAGE = CryptoPageToken(_page); // PAGE ADDRESS
    }

    mapping(string => uint256) private _addresses;
    function addMinter(string memory _key, uint256 amount) public onlyRole(DEFAULT_ADMIN_ROLE) {

        _addresses[_key] = amount;
    }

// minterCount

    function _amount_mint(string memory _key, uint256 _address_count) public view returns (uint256 amount_each, uint256 fee) {
        fee = _addresses[_key].mul(TreasuryFee).div(10000);
        amount_each = (_addresses[_key] - fee) / _address_count;
    }
    function mint(string memory _key, address [] memory _to) public onlyMinter() {
        uint256 address_count = _to.length;
        require(_addresses[_key] != 0, "Address Amount is 0");
        require(address_count < 5, "address count >= 5");
        require(address_count != 0, "address count is zero");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, address_count);

        // MINT TO ADDRESS
        for(uint256 i; i < address_count; i++){
            PAGE.mint(_to[i], amount_each);
        }

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee);
    }




    modifier onlyMinter() {        
        // require(_minters[msg.sender], "onlyMinter: caller is not the minter");
        _;
    }

    /*
    mapping (address => bool) public _minters;
    modifier onlyMinter() {        
        require(_minters[msg.sender], "onlyMinter: caller is not the minter");
        _;
    }
    function addMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      _minters[account] = true;
    }
    function removeMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
      _minters[account] = false;
    }
    */

}