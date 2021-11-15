// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

// MINTER
import "./CryptoPageMinter.sol";
import "./interfaces/INFTMINT.sol";

contract PageAdmin is Ownable {
    PageMinter public pageMinter;
    address public pageToken;
    // PageNFTBank public pageNFTBank;
    INFTMINT public pageNFT;

    address public treasuryAddress;

    constructor(address _treasuryAddress) {
        treasuryAddress = _treasuryAddress;
        pageMinter = new PageMinter(address(this), _treasuryAddress);
    }

    // INIT
    bool private oneTime = true;
    address[] private safeAddresses;

    modifier onlyAfterInit() {
        require(!oneTime, "INIT FUNCTION NOT CALLED");
        _;
    }

    function init(address _pageNFT, address _pageToken) public onlyOwner {
        require(oneTime, "CAN BE CALL ONLY ONCE");
        pageNFT = INFTMINT(_pageNFT);
        pageToken = _pageToken;
        pageMinter.init(_pageToken, _pageNFT);
        oneTime = false;
    }

    // ONLY ADMIN ???
    /*
    function removeMinter(string memory _key) public onlyOwner onlyAfterInit {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.removeMinter(_key);
    }

    function setMinter(
        string memory _key,
        address _account,
        uint256 _pageamount
    ) public onlyOwner onlyAfterInit {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.setMinter(_key, _account, _pageamount, false);
    }
    */
    function setTreasuryFee(uint256 _percent) public onlyOwner onlyAfterInit {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.setTreasuryFee(_percent);
    }

    function setTreasuryAddress(address _treasury)
        public
        onlyOwner
        onlyAfterInit
    {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.setTreasuryAddress(_treasury);
    }

    // ++++
    function addSafe(address[] memory _safe) public onlyOwner onlyAfterInit {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.addSafe(_safe); // memory
    }

    function removeSafe(address _safe) public onlyOwner onlyAfterInit {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.removeSafe(_safe);
    }

    function changeSafe(address _from, address _to)
        public
        onlyOwner
        onlyAfterInit
    {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.changeSafe(_from, _to);
    }

    function setBurnNFTCost(uint256 _pageamount)
        public
        onlyOwner
        onlyAfterInit
    {
        // require(!oneTime, "INIT FUNCTION NOT CALLED");
        pageMinter.setBurnNFTCost(_pageamount);
    }
}
