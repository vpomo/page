// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CryptoPageToken.sol";
import "./CryptoPageComment.sol";
import "./CryptoPageCommentMinter.sol";

contract PageNFT is ERC721("Page NFT", "PAGE-NFT"), ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    PageToken private token;
    PageCommentMinter private commentMinter;

    string public baseURL = "https://ipfs.io/ipfs/";
    address public treasury;
    uint256 public mintFee = 1000; // 100 is 1% || 10000 is 100%
    uint256 public burnFee = 0; // 100 is 1% || 10000 is 100%
    uint256 public amount = 9000000000000000000;
    uint256 public fee = 1000000000000000000;

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => address) private creatorById;

    constructor(
        address _treasury,
        PageToken _token,
        PageCommentMinter _commentMinter
    ) {
        treasury = _treasury;
        token = _token;
        commentMinter = _commentMinter;
    }

    function safeMint(string memory _tokenURI, bool _commentActive)
        public
        returns (uint256)
    {
        uint256 tokenId = _mint(msg.sender, _tokenURI);
        if (_commentActive) {
            commentMinter.activateComments(address(this), tokenId);
        }
        token.mint(msg.sender, amount);
        token.mint(treasury, fee);
        return (tokenId);
    }

    function burn(uint256 _tokenId) public {
        require(
            ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        token.burn(msg.sender, 10);
        _burn(_tokenId);
    }

    function _mint(address owner, string memory _tokenURI)
        private
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        creatorById[tokenId] = owner;
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return tokenId;
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    /*
    function burn(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }
    */

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

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(getBaseURL(), super.tokenURI(tokenId)));
    }

    function getBaseURL() public view returns (string memory) {
        return baseURL;
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
