// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// Import other contracts
import "./interfaces/IMINTER.sol";
import "./interfaces/INFTMINT.sol";
import "./interfaces/ISAFE.sol";

import "./CryptoPageComment.sol";

contract PageMinterNFT is ERC721, ERC721URIStorage, INFTMINT {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    IERC20 public pageToken;
    IMINTER public pageMinter;
    ISAFE private pageSafe;

    string private baseURL = "https://ipfs.io/ipfs/";

    constructor(address _pageMinter, address _pageToken)
        ERC721("Crypto Page NFT", "PAGE-NFT")
    {
        pageMinter = IMINTER(_pageMinter);
        pageSafe = ISAFE(_pageMinter);
        pageToken = IERC20(_pageToken);
    }

    /**
     *
     * - approved for NFT BANK
     *
     
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        override
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender) ||
            pageSafe.isSafe(spender));
    }
    **/
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
        /*
        if (_comment) {
            pageMinter.mint1("NFT_CREATE_WITH_COMMENT", msg.sender); // MINT
            PageComment newComment = new PageComment();
            commentsById[tokenId] = address(newComment);
        } else {
            pageMinter.mint1("NFT_CREATE", msg.sender); // MINT
        }
        */
        uint256 balance = pageToken.balanceOf(msg.sender);
        uint256 burnPrice = pageMinter.getBurnNFTCost();
        require((balance >= burnPrice), "not enoph PAGE tokens");
        pageMinter.burn(msg.sender, burnPrice);
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

    function creatorOf(uint256 tokenId) public view override returns (address) {
        return creatorById[tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function getTotalStatsByTokenId(uint256 _tokenId)
        public
        view
        returns (
            uint256 id,
            uint256 comments,
            uint256 likes,
            uint256 dislikes,
            address contractAddress
        )
    {
        require(
            commentsById[_tokenId] != address(0),
            "No comment functionaly for this nft"
        );

        contractAddress = commentsById[_tokenId];
        (uint256 _comments, uint256 _likes, uint256 _dislikes) = PageComment(
            contractAddress
        ).totalStats();

        id = _tokenId;
        comments = _comments;
        likes = _likes;
        dislikes = _dislikes;
    }

    function getCommentsByTokenId(uint256 _tokenId)
        public
        view
        returns (
            uint256[] memory uids,
            address[] memory authors,
            string[] memory texts,
            bool[] memory likes
        )
    {
        require(
            commentsById[_tokenId] != address(0),
            "No comment functionaly for this nft"
        );

        address _commentContract = commentsById[_tokenId];

        (
            uint256[] memory _uids,
            address[] memory _authors,
            string[] memory _texts,
            bool[] memory _likes
        ) = PageComment(_commentContract).getComments();
        uids = _uids;
        authors = _authors;
        texts = _texts;
        likes = _likes;
    }

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => address) private creatorById;

    function safeMint(string memory _tokenURI, bool _comment)
        public
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        uint256 amount = 10000000000000000000;
        if (_comment) {
            // pageMinter.mint1("NFT_CREATE_WITH_COMMENT", msg.sender); // MINT
            pageMinter.mint(msg.sender, amount);
            PageComment newComment = new PageComment();
            commentsById[tokenId] = address(newComment);
        } else {
            pageMinter.mint(msg.sender, amount);
            // pageMinter.mint1("NFT_CREATE", msg.sender); // MINT
        }
        creatorById[tokenId] = msg.sender;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return _tokenIdCounter.current();
    }

    function createCmment(
        uint256 _tokenId,
        string memory _commentText,
        bool _like
    ) public {
        require(msg.sender != address(0), "sender can't be zero address");
        require(_tokenId <= totalSupply(), "nonexistent token");
        require(
            commentsById[_tokenId] != address(0),
            "No comment functionaly for this nft"
        );
        PageComment commentContract = PageComment(commentsById[_tokenId]);
        commentContract.createComment(msg.sender, _commentText, _like);
        // address [] memory addresses;
        // addresses.push(msg.sender);
        // addresses.push(ownerOf(_tokenId));
        // addresses.push(creatorOf(_tokenId));
        // msg.sender, ownerOf(_tokenId), creatorOf(_tokenId)
        uint256 amount = 10000000000000000000;
        uint256 treasuryFee = 1000; // 100 is 1% || 10000 is 100%
        uint256 fee = amount.mul(treasuryFee).div(10000);
        uint256 amountEach = (amount - fee).div(3);

        pageMinter.mint(msg.sender, amountEach);
        pageMinter.mint(ownerOf(_tokenId), amountEach);
        pageMinter.mint(creatorOf(_tokenId), amountEach);
        // addresses.push(ownerOf(_tokenId));

        // "NFT_ADD_COMMENT",
        //
        // MINT
    }

    function commentActivate(uint256 _tokenId) public {
        require(_tokenId <= totalSupply(), "nonexistent token");
        require(commentsById[_tokenId] == address(0), "Comments alredy setup");
        require(
            ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        PageComment newComment = new PageComment();
        commentsById[_tokenId] = address(newComment);
        uint256 amount = 10000000000000000000;
        pageMinter.mint(msg.sender, amount); // MINT
    }

    /*
    function setBaseURL(string memory url) public override {
        require(msg.sender == pageMinter.getAdmin(), "only for admin");
        baseURL = url;
    }
    */

    function getBaseURL() public view override returns (string memory) {
        return baseURL;
    }
}
