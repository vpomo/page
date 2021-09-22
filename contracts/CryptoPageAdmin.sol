// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import '@openzeppelin/contracts/access/Ownable.sol';

// MINTER
import "./CryptoPageMinter.sol";

// NFT MARKETS
import "./CryptoPageNFTBank.sol";
import "./CryptoPageNFTMarket.sol";
import "./CryptoPageProfile.sol";

// TOKEN
import "./CryptoPageToken.sol";

import "./interfaces/INFTMINT.sol";



contract PageAdmin is Ownable {

    PageMinter public PAGE_MINTER;
    PageToken public PAGE_TOKEN;
    // PageNFTBank public PAGE_NFT_BANK;
    PageNFTMarket public PAGE_NFT_MARKET;
    PageProfile public PAGE_PROFILE;
    INFTMINT public PAGE_NFT;

    constructor() {
        // LAUNCH ADMIN
        PAGE_MINTER = new PageMinter(address(this),msg.sender);
        PAGE_TOKEN = new PageToken();

        // OTHERS

    }


    // INIT
    bool one_time = true;
    address[] private safeAddresses;
    function init( address _PAGE_NFT ) public onlyOwner() {
        require(one_time, "CAN BE CALL ONLY ONCE");

        address _PAGE_MINTER = address(PAGE_MINTER);

        PAGE_NFT = INFTMINT(_PAGE_NFT);

        PAGE_PROFILE = new PageProfile(_PAGE_MINTER);
        // PAGE_NFT_BANK = new PageNFTBank(_PAGE_NFT,_PAGE_MINTER);
        PAGE_NFT_MARKET = new PageNFTMarket(_PAGE_NFT,_PAGE_MINTER);

        // SETUP PAGE_TOKEN
        PAGE_MINTER.init(address(PAGE_TOKEN), address(PAGE_NFT));

        // SET SAFE ADDRESSES
        // safeAddresses.push(address(PAGE_NFT_BANK));
        safeAddresses.push(address(PAGE_NFT_MARKET));        
        PAGE_MINTER.addSafe(safeAddresses);

        /*
        PAGE_MINTER.addSafe(address(PAGE_MINTER));
        PAGE_MINTER.addSafe(address(PAGE_NFT_BANK));
        PAGE_MINTER.addSafe(address(PAGE_NFT_MARKET));
        PAGE_MINTER.addSafe(address(PAGE_PROFILE));
        */

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

    // ++++
    function addSafe( address[] memory _safe ) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.addSafe(_safe); // memory
    }
    function removeSafe( address _safe ) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.removeSafe(_safe);
    }
    function changeSafe( address _from, address _to ) public onlyOwner() {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.changeSafe(_from, _to);
    }

    function setBurnNFTcost( uint256 _pageamount ) public onlyOwner() {
        PAGE_MINTER.setBurnNFT(_pageamount);
    }
    function setNftBaseURL( string memory _url ) public onlyOwner() {
        PAGE_NFT.setBaseURL( _url );
    }
}
