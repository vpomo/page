// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
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
     **/
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

    function tokenComments(uint256 _tokenId)
        public
        view
        returns (
            uint256 id,
            uint256 comments,
            uint256 likes,
            uint256 dislikes,
            address _contract
        )
    {
        require(
            commentsById[_tokenId] != address(0),
            "No comment functionaly for this nft"
        );

        address _commentContract = commentsById[_tokenId];

        (uint256 _comments, uint256 _likes, uint256 _dislikes) = PageComment(
            _commentContract
        ).totalStats();

        id = _tokenId;
        comments = _comments;
        likes = _likes;
        dislikes = _dislikes;
        _contract = _commentContract;
    }

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => address) private creatorById;

    function safeMint(string memory _tokenURI, bool _comment)
        public
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        if (_comment) {
            pageMinter.mint1("NFT_CREATE_WITH_COMMENT", msg.sender); // MINT
            PageComment newComment = new PageComment();
            commentsById[tokenId] = address(newComment);
        } else {
            pageMinter.mint1("NFT_CREATE", msg.sender); // MINT
        }
        creatorById[tokenId] = msg.sender;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return _tokenIdCounter.current();
    }

    function comment(
        uint256 _tokenId,
        string memory _commentText,
        bool _like
    ) public {
        require(_tokenId <= totalSupply(), "nonexistent token");
        require(
            commentsById[_tokenId] != address(0),
            "No comment functionaly for this nft"
        );
        PageComment newComment = PageComment(commentsById[_tokenId]);
        newComment._comment(_commentText, _like, msg.sender);
        pageMinter.mint3(
            "NFT_ADD_COMMENT",
            msg.sender,
            ownerOf(_tokenId),
            creatorOf(_tokenId)
        ); // MINT
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
        pageMinter.mint1("NFT_CREATE_ADD_COMMENT", msg.sender); // MINT
    }

    function setBaseURL(string memory url) public override {
        require(msg.sender == pageMinter.getAdmin(), "only for admin");
        baseURL = url;
    }

    function getBaseURL() public view override returns (string memory) {
        return baseURL;
    }
}
