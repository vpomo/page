// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";
// import "./interfaces/INFTMINT.sol";
import "./interfaces/ISAFE.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PageMinter is IMINTER, ISAFE {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    IERCMINT private PAGE;

    address public TreasuryAddress = address(0);
    address private AdminAddress = address(0);
    uint256 public TreasuryFee = 1000; // 100 is 1% || 10000 is 100%

    // MINTERS
    Counters.Counter public _totalMinters;
    Counters.Counter public _minterId;
    // string[] public _listMinters;

    struct Minters {
        uint256 id;
        address author;
        uint256 amount;
        bool xmint;
    }
    mapping(string => Minters) public _minters;
    mapping(string => bool) private _keytank;

    /* INIT */
    constructor(address _admin, address _treasury) {   
        AdminAddress = _admin;     
        TreasuryAddress = _treasury; // setTreasuryAddress
    }

    bool private is_init = false;
    function init(address _page, address _nft) public onlyAdmin() {
        require(!is_init, "can be call only once");
        PAGE = IERCMINT(_page); // PAGE ADDRESS

        /* 
        PAGE_MINTER.addSafe(address(PAGE_MINTER));
        PAGE_MINTER.addSafe(address(PAGE_NFT_BANK));
        PAGE_MINTER.addSafe(address(PAGE_NFT_MARKET));
        PAGE_MINTER.addSafe(address(PAGE_PROFILE));
        */

        // setMinter("NFTBANK", address(_nft), 1 ** 18, true);

        /*** ***/
        setMinter("NFT_CREATE", _nft, 10000000000000000000, false);
        setMinter("NFT_CREATE_WITH_COMMENT", _nft, 10000000000000000000, false);
        setMinter("NFT_CREATE_ADD_COMMENT", _nft, 10000000000000000000, false);
        setMinter("NFT_ADD_COMMENT", _nft, 10000000000000000000, false);

        /*
        PAGE_TOKEN = IERCMINT(_PAGE_TOKEN);
        PAGE_NFT = INFTMINT(_PAGE_NFT);
        
        // PAGE
        PAGE_MINTER.setMinter("NFT_CREATE", address(PAGE_NFT), 20 ** 18, false);
        PAGE_MINTER.setMinter("NFT_CREATE_WITH_COMMENT", address(PAGE_NFT), 100 ** 18, false);
        PAGE_MINTER.setMinter("NFT_CREATE_ADD_COMMENT", address(PAGE_NFT), 80 ** 18, false); // if create without comments, it can be add by this function
        PAGE_MINTER.setMinter("NFT_FIRST_COMMENT", address(PAGE_NFT), 10 ** 18, false);
        PAGE_MINTER.setMinter("NFT_SECOND_COMMENT", address(PAGE_NFT), 3 ** 18, false);
        // PAGE_MINTER.setMinter("BANK_SELL", PAGE_NFT.BANK_ADDRESS, 1 ** 18, true); // On the price effect amount of comments
        // PAGE_MINTER.setMinter("PROFILE_UPDATE", address(PAGE_NFT), 3 ** 18, false);
        */
        is_init = true;
    }

    function _amount_mint(string memory _key, uint256 _address_count) public view override returns (uint256 amount_each, uint256 fee) {
        require(_keytank[_key], "_amount_mint: _key doesn't exists");        
        require(_address_count < 5, "address count > 4");
        require(_address_count > 0, "address count is zero");
        // (address author, uint256 amount) = _minters[_key];
        Minters storage minter = _minters[_key];
        fee = minter.amount.mul(TreasuryFee).div(10000);
        amount_each = (minter.amount - fee).div(_address_count);
    }
    function mint(string memory _key, address [] memory _to) public override{        
        require(is_init, "need to be init by admin");
        require(_keytank[_key], "mint: _key doesn't exists");

        // MINTER ONLY
        Minters storage minter =  _minters[_key];        
        require(minter.amount > 0, "mint: minter.amount can't be 0");
        require(minter.author == msg.sender, "mint: not minter");        

        uint256 address_count = _to.length;
        // require(_addresses[_key] != 0, "Address Amount is 0");
        require(address_count < 5, "address count > 4");
        require(address_count > 0, "address count is zero");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, address_count);

        // MINT TO ADDRESS
        for(uint256 i; i < address_count; i++){
            PAGE.mint(_to[i], amount_each);
        }

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee);
    }

    function mint1(string memory _key, address _to) public override{        
        require(is_init, "need to be init by admin");
        require(_keytank[_key], "mint: _key doesn't exists");

        // MINTER ONLY
        Minters storage minter =  _minters[_key];        
        require(minter.amount > 0, "mint: minter.amount can't be 0");
        require(minter.author == msg.sender, "mint: not minter");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, 1);

        // MINT TO ADDRESS
        PAGE.mint(_to, amount_each);

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee);
    }

    function mint2(string memory _key, address _to1, address _to2) public override{ 
        require(is_init, "need to be init by admin");
        require(_keytank[_key], "mint: _key doesn't exists");

        // MINTER ONLY
        Minters storage minter =  _minters[_key];        
        require(minter.amount > 0, "mint: minter.amount can't be 0");
        require(minter.author == msg.sender, "mint: not minter");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, 2);

        // MINT TO ADDRESS
        PAGE.mint(_to1, amount_each);
        PAGE.mint(_to2, amount_each);

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee);
    }
    function mint3(string memory _key, address _to1, address _to2, address _to3) public override{ 
        require(is_init, "need to be init by admin");
        require(_keytank[_key], "mint: _key doesn't exists");

        // MINTER ONLY
        Minters storage minter =  _minters[_key];        
        require(minter.amount > 0, "mint: minter.amount can't be 0");
        require(minter.author == msg.sender, "mint: not minter");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, 3);

        // MINT TO ADDRESS
        PAGE.mint(_to1, amount_each);
        PAGE.mint(_to2, amount_each);
        PAGE.mint(_to3, amount_each);

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee);
    } 

    function mintX(string memory _key, address [] memory _to, uint _multiplier) public override{
        require(is_init, "need to be init by admin");
        require(_keytank[_key], "mintX: _key doesn't exists");

        // MINTER ONLY
        Minters storage minter =  _minters[_key];        
        require(minter.amount > 0, "mint: minter.amount can't be 0");
        require(minter.author == msg.sender, "mint: not minter");
        require(minter.xmint, "xmint: not active");

        uint256 address_count = _to.length;
        // require(_addresses[_key] != 0, "Address Amount is 0");
        require(address_count < 5, "address count > 4");
        require(address_count > 0, "address count is zero");

        (uint256 amount_each, uint256 fee) = _amount_mint(_key, address_count);

        // MINT TO ADDRESS
        for(uint256 i; i < address_count; i++){
            PAGE.mint(_to[i], amount_each.mul(_multiplier));
        }

        // FEE TO ADDRESS
        PAGE.mint(TreasuryAddress, fee.mul(_multiplier));
    }

    // > > > onlyAdmin < < <  
    modifier onlyAdmin() {        
        require(msg.sender == AdminAddress, "onlyAdmin: caller is not the admin");
        _;
    }
    function removeMinter(string memory _key) public onlyAdmin() override {
        require(_keytank[_key], "removeMinter: _key doesn't exists");
        _keytank[_key] = false;
        // Minters memory toRemove = _minters[_key];
        // delete _listMinters[toRemove.id];
        delete _minters[_key];
        _totalMinters.decrement();
    }
    function setMinter(string memory _key, address _account, uint256 _pageamount, bool _xmint) public  onlyAdmin() override {
        if (_keytank[_key]) {
            Minters memory update = _minters[_key];
            update.amount = _pageamount;
            update.author = _account;
            update.xmint = _xmint;
        } else {
            _keytank[_key] = true;
            _minters[_key] = Minters({
                author: _account,
                amount: _pageamount,
                id: _minterId.current(),
                xmint: _xmint
            });
            // _listMinters[_minterId.current()] = _key;
            _minterId.increment();
            _totalMinters.increment();
        }
    }



    function testLastinterID() public view returns (uint256) {
        return _minterId.current();
    }
    function setTreasuryFee(uint256 _percent) public onlyAdmin() {
        require(_percent >= 10, "setTreasuryFee: minimum treasury fee percent is 0.1%");
        require(_percent <= 3000, "setTreasuryFee: maximum treasury fee percent is 30%");
        TreasuryFee = _percent;
    }
    function setTreasuryAddress(address _treasury) public onlyAdmin() {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        TreasuryAddress = _treasury;
    }

    // GET FUNCTIONS
    function getMinter(string memory _key) public view override returns (
        uint256 id,
        address author,
        uint256 amount,
        bool xmint) {
        require(_keytank[_key], "getMinter: _key doesn't exists");
        Minters memory minter = _minters[_key];
        id = minter.id;
        author = minter.author;
        amount = minter.amount;
        xmint = minter.xmint;
    }

    // PROXY
    function burn( address from, uint256 amount ) public override onlySafe() {
        require(is_init, "need to be init by admin");

        // burn 100% PAGE
        PAGE.xburn(from, amount);

        // recover 10% to Treasury address
        PAGE.mint(TreasuryAddress, amount.mul(TreasuryFee).div(10000));
    }

    // ISAFE
    mapping(address => bool) private safeList;
    function isSafe( address _safe ) public override view returns (bool) {
        return safeList[_safe];
    }
    function addSafe( address[] memory _safe ) public override onlyAdmin() {        
        for(uint256 i; i < _safe.length; i++){
            safeList[_safe[i]] = true;
        }        
    }
    function removeSafe( address _safe ) public override onlyAdmin() {
        safeList[_safe] = false;        
    }
    function changeSafe( address _from, address _to ) public override onlyAdmin() {
        safeList[_from] = false;
        safeList[_to] = true;       
    }
    modifier onlySafe() {        
        require(isSafe(msg.sender), "onlySafe: caller is not in safe list");
        _;
    }

    // DESTROY NFT
    uint256 private CostBurnNFT;
    function setBurnNFT(uint256 _cost) public override onlyAdmin() {
        CostBurnNFT = _cost;
    }
    // VIEW FUNCTIONS
    function getBurnNFT() public override view returns (uint256) {
        return CostBurnNFT;
    }
    function getAdmin() public override view returns (address) {
        return AdminAddress;
    }
    function getPageToken() public override view returns (address) {
        return address(PAGE);
    }

}