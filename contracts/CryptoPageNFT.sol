// SPDX-License-Identifier: MIT

pragma solidity 0.8.3;

// import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageBank.sol";

/// @title Contract of PAGE.NFT token
/// @author Crypto.Page Team
/// @notice
/// @dev
contract PageNFT is Initializable, ERC721URIStorageUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    CountersUpgradeable.Counter public _tokenIdCounter;
    // IPageCommentDeployer public commentDeployer;
    IPageComment public comment;
    IPageBank public bank;
    string private _name;
    string private _symbol;
    string public baseURL;

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => uint256) private pricesById;
    mapping(uint256 => address) private creatorById;
    mapping(bytes32 => uint256[]) private tokensIdsByCollectionName;
    mapping(address => EnumerableSetUpgradeable.Bytes32Set) private collectionsByAddress;

    /// @notice Initial function
    /// @param _comment Address of our PageCommentMinter contract
    /// @param _bank Address of our PageBank contract
    /// @param _baseURL BaseURL of tokenURI, i.e. https://ipfs.io/ipfs/
    function initialize(
        address _comment,
        address _bank,
        string memory _baseURL
    ) public payable initializer {
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        comment = IPageComment(_comment);
        bank = IPageBank(_bank);
        baseURL = _baseURL;
    }

    /// @notice Mint PAGE.NFT token
    /// @param owner Address of token owner
    /// @param tokenURI URI of token
    function safeMint(
        address owner,
        string memory tokenURI,
        bytes32 collectionName
    ) public override returns (uint256 tokenId) {
        uint256 gasBefore = gasleft();
        require(owner != address(0), "Address can't be null");
        tokenId = _safeMint(owner, tokenURI);
        tokensIdsByCollectionName[
            keccak256(abi.encodePacked(_msgSender(), collectionName))
        ].push(tokenId);
        collectionsByAddress[_msgSender()].add(keccak256(abi.encodePacked(_msgSender(), collectionName)));
        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.calculateMint(_msgSender(), owner, gas);
        pricesById[tokenId] = price;
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
        uint256 commentsReward = comment.calculateCommentsReward(
            address(this),
            tokenId
        );
        // console.log("commentsReward in safeBurn %s", commentsReward);
        /*
        IPageComment.Comment[] memory comments = comment.getComments(
            address(this),
            tokenId
        );
        for (uint256 i = 0; i < comments.length; i++) {Для того
            IPageComment.Comment memory commentInstance = comments[i];
            // If author of the comment is not sender
            // Need to calculate 45% of comment.price
            // This is an equivalent reward for comment
            if (commentInstance.author != _msgSender()) {
                commentsReward.add(commentInstance.price.div(100).mul(45));
            }
         }
        */
        // Check the amount of gas after counting awards for comments
        uint256 gasAfter = gasBefore - gasleft();
        bank.calculateBurn(_msgSender(), gasAfter, commentsReward);
        _safeBurn(tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param from Approved or owner of token
    /// @param to Receiver of token
    /// @param tokenId Id of token
    function safeTransferFrom2(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        // ) public override(IERC721Upgradeable, ERC721Upgradeable) {
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

    function getTokensIdsByCollectionName(bytes32 collectionName)
        public
        view
        override
        returns (uint256[] memory tokenIds)
    {
        return tokensIdsByCollectionName[collectionName];
    }

    function getTokensURIsByCollectionName(bytes32 collectionName)
        public
        view
        override
        returns (string[] memory tokenURIs)
    {
        for (
            uint256 i = 0;
            i > tokensIdsByCollectionName[collectionName].length;
            i++
        ) {
            tokenURIs[i] = tokenURI(
                tokensIdsByCollectionName[collectionName][i]
            );
        }
    }

    function getCollectionsByAddress(address _address)
        public
        view
        override
        returns (bytes32[] memory collectionNames)
    {
        return collectionsByAddress[_address].values();
    }
}