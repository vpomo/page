// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

// MINTER
import "./CryptoPageMinter.sol";
import "./interfaces/INFTMINT.sol";

contract PageAdmin is Ownable {
    PageMinter public PAGE_MINTER;
    address public PAGE_TOKEN;
    // PageNFTBank public PAGE_NFT_BANK;
    INFTMINT public PAGE_NFT;

    address public TreasuryAddress;

    constructor(address _TreasuryAddress) {
        TreasuryAddress = _TreasuryAddress;
        PAGE_MINTER = new PageMinter(address(this), _TreasuryAddress);
    }

    // INIT
    bool one_time = true;
    address[] private safeAddresses;

    function init(address _PAGE_NFT, address _PAGE_TOKEN) public onlyOwner {
        require(one_time, "CAN BE CALL ONLY ONCE");
        PAGE_NFT = INFTMINT(_PAGE_NFT);
        PAGE_TOKEN = _PAGE_TOKEN;
        PAGE_MINTER.init(_PAGE_TOKEN, _PAGE_NFT);
        one_time = false;
    }

    // ONLY ADMIN
    function removeMinter(string memory _key) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.removeMinter(_key);
    }

    function setMinter(
        string memory _key,
        address _account,
        uint256 _pageamount
    ) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setMinter(_key, _account, _pageamount, false);
    }

    function setTreasuryFee(uint256 _percent) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setTreasuryFee(_percent);
    }

    function setTreasuryAddress(address _treasury) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.setTreasuryAddress(_treasury);
    }

    // ++++
    function addSafe(address[] memory _safe) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.addSafe(_safe); // memory
    }

    function removeSafe(address _safe) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.removeSafe(_safe);
    }

    function changeSafe(address _from, address _to) public onlyOwner {
        require(!one_time, "INIT FUNCTION NOT CALLED");
        PAGE_MINTER.changeSafe(_from, _to);
    }

    function setBurnNFTcost(uint256 _pageamount) public onlyOwner {
        PAGE_MINTER.setBurnNFT(_pageamount);
    }

    function setNftBaseURL(string memory _url) public onlyOwner {
        PAGE_NFT.setBaseURL(_url);
    }
}
