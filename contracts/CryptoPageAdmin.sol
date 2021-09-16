// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./CryptoPageMinter.sol";
import "./CryptoPageNFT.sol";
import "./CryptoPageNFTBank.sol";
import "./interfaces/IERCMINT.sol";
contract PageAdmin is Ownable {
    IERCMINT public PAGE_TOKEN;
    PageMinter public PAGE_MINTER;
    PageMinterNFT public PAGE_MINTER_NFT;
    constructor(
        // address _PAGE_MINTER, 
        // address _PAGE_MINTER_NFT
        ) {
        PAGE_MINTER = new PageMinter(address(this),msg.sender,msg.sender);

        // NEED TO BE START FROM IT
        // PAGE_MINTER_NFT = new PageMinterNFT(address(PAGE_MINTER));
    }


    // INIT
    bool one_time = true;
    function init() public onlyOwner() {
        require(one_time, "CAN BE CALL ONLY ONCE");

        // PAGE
        PAGE_MINTER.setMinter("NFT_CREATE", address(PAGE_MINTER_NFT), 20 ** 18, false);
        PAGE_MINTER.setMinter("NFT_CREATE_WITH_COMMENT", address(PAGE_MINTER_NFT), 100 ** 18, false);
        PAGE_MINTER.setMinter("NFT_CREATE_ADD_COMMENT", address(PAGE_MINTER_NFT), 80 ** 18, false); // if create without comments, it can be add by this function
        PAGE_MINTER.setMinter("NFT_FIRST_COMMENT", address(PAGE_MINTER_NFT), 10 ** 18, false);
        PAGE_MINTER.setMinter("NFT_SECOND_COMMENT", address(PAGE_MINTER_NFT), 3 ** 18, false);
        // PAGE_MINTER.setMinter("BANK_SELL", PAGE_MINTER_NFT.BANK_ADDRESS, 1 ** 18, true); // On the price effect amount of comments
        PAGE_MINTER.setMinter("PROFILE_UPDATE", address(PAGE_MINTER_NFT), 3 ** 18, false);
        one_time = false;
    }

    // ONLY ADMIN
    function removeMinter(string memory _key) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.removeMinter(_key);
    }
    function setMinter(string memory _key, address _account, uint256 _pageamount) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setMinter(_key, _account, _pageamount, false);
    }
    function setTreasuryFee(uint256 _percent) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setTreasuryFee(_percent);
    }
    function setTreasuryAddress(address _treasury) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setTreasuryAddress(_treasury);
    }
}