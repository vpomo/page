// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./CryptoPageTokenMinter.sol";
// import "./CryptoPageNFTMinter.sol";
import "./CryptoPageNFT.sol";
import "./CryptoPageCommentMinter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Import other contracts
// import "./interfaces/IMINTER.sol";
// import "./interfaces/INFTMINT.sol";
// import "./interfaces/ISAFE.sol";

// import "./CryptoPageComment.sol";

contract PageNFTMinter is Ownable {
    // IERC20 public pageToken;
    PageCommentMinter private commentMinter;
    PageTokenMinter private tokenMinter;
    // PageNFTMinter private nftMinter;
    PageNFT private nft;
    // ISAFE private pageSafe;

    // uint256 amount = 10000000000000000000;
    // string private baseURL = "https://ipfs.io/ipfs/";

    address private treasury;
    uint256 private mintFee = 1000; // 100 is 1% || 10000 is 100%
    uint256 private burnFee = 0; // 100 is 1% || 10000 is 100%

    constructor(
        address _treasury,
        PageTokenMinter _tokenMinter,
        PageNFT _nft,
        PageCommentMinter _commentMinter
    ) {
        treasury = _treasury;
        tokenMinter = _tokenMinter;
        commentMinter = _commentMinter;
        nft = _nft;
        // pageMinter = IMINTER(_pageMinter);
        // pageSafe = ISAFE(_pageMinter);
        // pageToken = IERC20(_pageToken);
    }

    /*
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
    

    function burn(uint256 _tokenId) public override {
        require(
            ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        uint256 balance = pageToken.balanceOf(msg.sender);
        uint256 burnPrice = pageMinter.getBurnNFTCost();
        require((balance >= burnPrice), "not enoph PAGE tokens");
        pageMinter.burn(msg.sender, burnPrice);
        _burn(_tokenId);
    }

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => address) private creatorById;
    */

    function safeMint(string memory _tokenURI, bool _commentActive)
        public
        returns (uint256)
    {
        // uint256 tokenId = _tokenIdCounter.current();
        // uint256 totalAmount = 10000000000000000000;
        uint256 amount = 9000000000000000000;
        uint256 fee = 1000000000000000000;
        uint256 tokenId = nft.mint(msg.sender, _tokenURI);
        if (_commentActive) {
            // tokenMinter.mint(msg.sender, amount);
            commentMinter.activateComment(address(nft), tokenId);
            // pageMinter.mint(msg.sender, amount);
            // PageComment newComment = new PageComment();
            // commentsById[tokenId] = address(newComment);
        }
        tokenMinter.mint(msg.sender, amount);
        tokenMinter.mint(treasury, fee);
        // creatorById[tokenId] = msg.sender;
        // _safeMint(msg.sender, tokenId);
        // _setTokenURI(tokenId, _tokenURI);
        // _tokenIdCounter.increment();
        // return _tokenIdCounter.current();
        return (tokenId);
    }

    function burn(uint256 _tokenId) public {
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        // uint256 balance = pageToken.balanceOf(msg.sender);
        // uint256 burnPrice = pageMinter.getBurnNFTCost();
        // require((balance >= burnPrice), "not enoph PAGE tokens");
        tokenMinter.burn(msg.sender, 10);
        nft.burn(_tokenId);
    }

    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        treasury = _treasury;
    }

    function setBurnFee(uint256 _percent) public onlyOwner {
        require(_percent >= 10, "setBurnFee: minimum burn fee percent is 0.1%");
        require(
            _percent <= 3000,
            "setBurnFee: maximum burn fee percent is 30%"
        );
        burnFee = _percent;
    }

    function setMintFee(uint256 _percent) public onlyOwner {
        require(_percent >= 10, "setMintFee: minimum mint fee percent is 0.1%");
        require(
            _percent <= 3000,
            "setMintFee: maximum mint fee percent is 30%"
        );
        mintFee = _percent;
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
}
