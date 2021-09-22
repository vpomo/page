// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import "@openzeppelin/contracts/utils/Counters.sol";



import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import other contracts
import "./interfaces/IMINTER.sol";
import "./interfaces/INFTMINT.sol";
import "./interfaces/ISAFE.sol";

import "./CryptoPageComment.sol";

contract PageMinterNFT is ERC721, ERC721URIStorage, INFTMINT {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    IERC20 public PAGE_TOKEN;
    IMINTER public PAGE_MINTER;
    ISAFE private PAGE_SAFE;

    constructor(address _PAGE_MINTER, address _PAGE_TOKEN) ERC721("Crypto Page NFT", "PAGE-NFT")  {
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
        PAGE_SAFE = ISAFE(_PAGE_MINTER);
        PAGE_TOKEN = IERC20(_PAGE_TOKEN);
    }

    /**
     *
     * - approved for NFT BANK
     *
     **/
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual override returns (bool)  {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender) || PAGE_SAFE.isSafe(spender));
    }
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }  
    function burn(uint256 _tokenId) public override{
        require(ownerOf(_tokenId) == msg.sender, "It's possible only for owner");        
        uint256 BALANCE = PAGE_TOKEN.balanceOf(msg.sender);
        uint256 BURN_PRICE = PAGE_MINTER.getBurnNFT();
        require((BALANCE >= BURN_PRICE), "not enoph PAGE tokens");
        PAGE_MINTER.burn(msg.sender, BURN_PRICE);
        _burn(_tokenId);
    }
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(getBaseURL(), super.tokenURI(tokenId)));
    }
    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _tokenIdCounter.current();
    }
    function tokenComments(uint256 _tokenId) public view returns(
        uint256 id,
        uint256 comments,
        uint256 likes,
        uint256 dislakes,
        address _contract) {
            require(commentsById[_tokenId] != address(0), "No comment functionaly for this nft");
        
        address Contract = commentsById[_tokenId];
        (uint256 Comments, uint256 Likes, uint256 Dislakes) = PageComment(Contract).totalStats();
        id = _tokenId;
        comments = Comments;
        likes = Likes;
        dislakes = Dislakes;
        _contract = Contract;
    }
    mapping(uint256 => address) private commentsById;
    function safeMint(string memory _tokenURI, bool _comment) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        if (_comment) {
            PageComment newComment = new PageComment();
            commentsById[tokenId] = address(newComment);
        }
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return _tokenIdCounter.current();
    }

    function comment(uint256 _tokenId, string memory _comment_text, bool _like) public {
        require(_tokenId <= totalSupply(), "nonexistent token");
        require(commentsById[_tokenId] != address(0), "No comment functionaly for this nft");
        PageComment newComment = PageComment(commentsById[_tokenId]);
        newComment._comment(_comment_text, _like, msg.sender);
    }

    function commentActivate(uint256 _tokenId) public {
        require(_tokenId <= totalSupply(), "nonexistent token");
        require(commentsById[_tokenId] == address(0), "Comments alredy setup");
        require(ownerOf(_tokenId) == msg.sender, "It's possible only for owner");
        PageComment newComment = new PageComment();           
        commentsById[_tokenId] = address(newComment); 
    }

    string private BaseURL = "https://ipfs.io/ipfs/";
    function setBaseURL( string memory url ) public override {
        require(msg.sender == PAGE_MINTER.getAdmin(), "only for admin");
        BaseURL = url;
    }
    function getBaseURL() public override view returns (string memory) {
        return BaseURL;
    }
}
