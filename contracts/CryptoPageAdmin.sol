// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
// import "./CryptoPageTokenMinter.sol";
// import "./CryptoPageMinter.sol";
import "./CryptoPageToken.sol";
import "./CryptoPageTokenMinter.sol";
import "./CryptoPageNFT.sol";
import "./CryptoPageNFTMinter.sol";

// import "./CryptoPageMinterNFT.sol";
// import "./interfaces/INFTMINT.sol";
// import "./interfaces/IMINTER.sol";

// import "./interfaces/ICryptoPageComment.sol";

contract PageAdmin is Ownable {
    address public treasury;
    // PageToken public token;
    PageTokenMinter public tokenMinter;
    PageNFTMinter public nftMinter;

    // IERCMINT public pageToken;
    // PageToken public pageToken;
    // PageMinterNFT public pageMinterNFT;
    // INFTMINT public pageNFT;
    // address public pageToken;

    // bool private oneTime = true;

    constructor(
        address _treasury,
        PageTokenMinter _tokenMinter,
        PageNFTMinter _nftMinter // PageToken _token, // PageNFT _nft // INFTMINT _pageNFT, // IERCMINT _pageToken
    ) {
        treasury = _treasury;
        tokenMinter = _tokenMinter;
        nftMinter = _nftMinter;
        // token = _token;
        // nft = _nft;
        // pageMinter = _pageMinter;
        // pageNFT = _pageNFT;
        // pageToken = _pageToken;
        // require(oneTime, "CAN BE CALL ONLY ONCE");
        // pageNFT = INFTMINT(_pageNFT);
        //
        // pageMinter.init(_pageToken, _pageNFT);
        // oneTime = false;
        // pageMinter = new PageMinter(address(this), _treasuryAddress);
    }

    /*
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
    */
    /*
    function setTokenMintFee(uint256 _percent) public onlyOwner {
        // pageMinter.setTreasuryFee(_percent);
    }

    function setTokenBurnFee(uint256 _percent) public onlyOwner {
        // pageMinter.setTreasuryFee(_percent);
    }
    */
    function setMintFee(uint256 _percent) public onlyOwner {
        // pageMinter.setTreasuryFee(_percent);
        nftMinter.setMintFee(_percent);
    }

    function setBurnFee(uint256 _percent) public onlyOwner {
        // pageMinter.setTreasuryFee(_percent);
        // tokenMinter.setTreasury(_treasury);
        nftMinter.setBurnFee(_percent);
    }

    function setTreasury(address _treasury) public onlyOwner {
        // tokenMinter.setTreasury(_treasury);
        nftMinter.setTreasury(_treasury);
    }
    /*
    function setBurnNFTCost(uint256 _pageamount) public onlyOwner {
        pageMinter.setBurnNFTCost(_pageamount);
    }
    */
}
