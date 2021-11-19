// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// import "./interfaces/IMINTER.sol";
// import "./interfaces/IERCMINT.sol";
// import "./interfaces/INFTMINT.sol";
// import "./interfaces/ISAFE.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
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
    // uint256 private burnNFTCost = 0;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    // bool private isReady = false;

    /* INIT */
    constructor(
        // address _admin,
        // address _treasury,
        // PageNFTMinter _nftMinter,
        PageToken _token
    ) {
        // admin = _admin;
        // treasury = _treasury; // setTreasuryAddress
        token = _token;
        _setupRole(DEFAULT_ADMIN_ROLE, owner());
        // _setupRole(MINTER_ROLE, address(_nftMinter));
        // _setupRole(BURNER_ROLE, address(_nftMinter));
    }

    /*
    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "onlyAdmin: caller is not the admin"
        );
        _;
    }
    
    modifier onlyBurner() {
        require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");
        _;
    }

    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _;
    }
    */
    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        // require(isReady, "need to be init by admin");
        // FEE TO ADDRESS
        // uint256 fee = amount.mul(treasuryFee).div(10000);

        // MINT TO ADDRESS
        // page.mint(_to, amount);

        // FEE TO TREASURY ADDRESS
        // page.mint(treasuryAddress, fee);
        token.mint(_to, _amount);
    }

    // PROXY
    function burn(address _from, uint256 _amount) public onlyRole(BURNER_ROLE) {
        // require(isReady, "need to be init by admin");
        // require(hasRole(BURNER_ROLE, msg.sender), "Caller is not a burner");

        // burn 100% PAGE
        // page.burnFrom(from, amount);

        // recover 10% to Treasury address
        // page.mint(treasuryAddress, amount.mul(treasuryFee).div(10000));
        token.burn(_from, _amount);
    }
    /*
    function setBurnNFTCost(uint256 _cost) public override onlyAdmin {
        burnNFTCost = _cost;
    }
    
    function setTreasuryFee(uint256 _percent) public onlyAdmin {
        require(
            _percent >= 10,
            "setTreasuryFee: minimum treasury fee percent is 0.1%"
        );
        require(
            _percent <= 3000,
            "setTreasuryFee: maximum treasury fee percent is 30%"
        );
        treasuryFee = _percent;
    }
    */
    /*
    function setTreasuryAddress(address _treasury) public onlyAdmin {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        treasuryAddress = _treasury;
    }
    */
    // VIEW FUNCTIONS
    /*
    function getBurnNFTCost() public view override returns (uint256) {
        return burnNFTCost;
    }
    */

    /*
    function setBurnFee(uint256 _percent) public onlyOwner {
        require(
            _percent >= 10,
            "setBurnFee: minimum treasury fee percent is 0.1%"
        );
        require(
            _percent <= 3000,
            "setBurnFee: maximum treasury fee percent is 30%"
        );
        burnFee = _percent;
    }
    
    function setMintFee(uint256 _percent) public onlyOwner {
        require(
            _percent >= 10,
            "setTreasuryMintFee: minimum treasury fee percent is 0.1%"
        );
        require(
            _percent <= 3000,
            "setTreasuryMintFee: maximum treasury fee percent is 30%"
        );
        mintFee = _percent;
    }
    
    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        treasury = _treasury;
    }

    function getAdmin() public view returns (address) {
        return admin;
    }

    function getTreasury() public view returns (address) {
        return treasury;
    }

    function getMintFee() public view returns (uint256) {
        return mintFee;
    }

    function getBurnFee() public view returns (uint256) {
        return burnFee;
    }

    function getToken() public view returns (address) {
        return address(token);
    }
    */
}
