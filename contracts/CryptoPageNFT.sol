// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Counters.sol";

// Import other contracts
import "./CryptoPageComment.sol";
import './CryptoPageMinter.sol';

contract PageMinterNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    PageMinter MINTER = PageMinter(address(0));

    // account => stakingId[]
    // mapping(address => EnumerableSet.UintSet) private stakingIdsOf;

    // TOKENS DEPOSIT
    // getStakingToken.transferFrom(msg.sender, address(this), COIN);

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function totalSupply()
        public
        view
        returns (uint256)
    {
        return _tokenIdCounter.current();
    }

    constructor() ERC721("Crypto Page NFT", "PAGE-NFT")  {}


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


    function safeMint(string memory _tokenURI, bool _comment) public {
        uint256 tokenId = _tokenIdCounter.current();
        if (_comment) {
            PageComment newComment = new PageComment();
            commentsById[tokenId] = address(newComment);
        }
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
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

    // RECOVER FUNCTIONS
    function withdrawAll() public payable onlyOwner {
        uint256 _each = address(this).balance;
        require(payable(msg.sender).send(_each));        
    }
}
