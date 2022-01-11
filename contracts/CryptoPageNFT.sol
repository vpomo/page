// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";

import "./interfaces/ICryptoPageCommentDeployer.sol";
import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageBank.sol";

/// @title Contract of PAGE.NFT token
/// @author Crypto.Page Team
/// @notice
/// @dev
contract PageNFT is ERC721URIStorageUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;

    CountersUpgradeable.Counter public _tokenIdCounter;
    IPageCommentDeployer public commentDeployer;
    IPageBank public bank;
    string private _name;
    string private _symbol;
    string public baseURL;

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => uint256) private pricesById;
    mapping(uint256 => address) private creatorById;

    /// @notice Initial function
    /// @param _commentDeployer Address of our PageCommentMinter contract
    /// @param _bank Address of our PageBank contract
    /// @param _baseURL BaseURL of tokenURI, i.e. https://ipfs.io/ipfs/
    function initialize(
        address _commentDeployer,
        address _bank,
        string memory _baseURL
    ) public payable initializer {
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        // __Ownable_init_unchained();
        commentDeployer = IPageCommentDeployer(_commentDeployer);
        bank = IPageBank(_bank);
        baseURL = _baseURL;
    }

    /// @notice Mint PAGE.NFT token
    /// @param owner Address of token owner
    /// @param tokenURI URI of token
    /// @return TokenId
    function safeMint(address owner, string memory tokenURI)
        public
        override
        returns (uint256)
    {
        uint256 gasBefore = gasleft();
        require(_msgSender() != address(0), "Address can't be null");
        require(owner != address(0), "Address can't be null");
        uint256 tokenId = _safeMint(owner, tokenURI);
        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.calculateMint(_msgSender(), owner, gas);
        pricesById[tokenId] = price;
        return tokenId;
    }

    /// @notice Mint PAGE.NFT token
    /// @param _owner Address of token owner
    /// @param _tokenURI URI of token
    /// @return TokenId
    function _safeMint(address _owner, string memory _tokenURI)
        private
        returns (uint256)
    {
        uint256 tokenId = _mint(_owner, _tokenURI);
        return tokenId;
    }

    /// @notice Burn PAGE.NFT token
    /// @param tokenId Id of token
    function safeBurn(uint256 tokenId) public override {
        // Check the amount of gas before counting awards for comments
        uint256 gasBefore = gasleft();
        require(ownerOf(tokenId) == _msgSender(), "Allower only for owner");
        uint256 commentsReward;
        bool commentsExists = commentDeployer.isExists(address(this), tokenId);
        if (commentsExists) {
            IPageComment commentContract = IPageComment(
                commentDeployer.getCommentContract(address(this), tokenId)
            );
            IPageComment.Comment[] memory comments = commentContract
                .getComments();
            for (uint256 i = 0; i < comments.length; i++) {
                IPageComment.Comment memory comment = comments[i];
                // If author of the comment is not sender
                // Need to calculate 45% of comment.price
                // This is an equivalent reward for comment
                if (comment.author != _msgSender()) {
                    commentsReward.add(comment.price.div(100).mul(45));
                }
            }
        }
        // Check the amount of gas after counting awards for comments
        uint256 gasAfter = gasBefore - gasleft();
        bank.calculateBurn(_msgSender(), gasAfter, commentsReward);
        _safeBurn(tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param from Approved or owner of token
    /// @param to Receiver of token
    /// @param tokenId Id of token
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(ERC721Upgradeable, IERC721Upgradeable) {
        uint256 gasBefore = gasleft();
        require(from != address(0), "Address can't be null");
        require(to != address(0), "Address can't be null");
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner or approved"
        );
        _safeTransfer(from, to, tokenId, "");
        uint256 amount = gasBefore - gasleft();
        bank.calculateMint(from, to, amount);
    }

    /// @notice Burn PAGE.NFT token
    /// @param _tokenId Id of token
    function _safeBurn(uint256 _tokenId) private {
        _burn(_tokenId);
    }

    /// @notice Mint PAGE.NFT token
    /// @param _owner Address of token owner
    /// @param _tokenURI URI of token
    /// @return TokenId
    function _mint(address _owner, string memory _tokenURI)
        private
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        creatorById[tokenId] = _owner;
        _safeMint(_owner, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return tokenId;
    }

    /// @notice Return price of token
    /// @param tokenId URI of token
    /// @return Price of PAGE.NFT token in PAGE tokens
    function tokenPrice(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return pricesById[tokenId];
    }
}
