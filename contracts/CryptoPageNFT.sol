// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Upgradeable.sol";

import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageBank.sol";

/// @title Contract of PAGE.NFT token
/// @author Crypto.Page Team
/// @notice
/// @dev //https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/master/contracts
contract PageNFT is Initializable, ERC721URIStorageUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    CountersUpgradeable.Counter public _tokenIdCounter;
    // IPageCommentDeployer public commentDeployer;
    IPageComment public comment;
    IPageBank public bank;
    string private _name;
    string private _symbol;
    string public baseURL;

    mapping(uint256 => uint256) private pricesById;
    mapping(uint256 => address) private creatorById;
    mapping(address => mapping(bytes32 => uint256[]))
        private tokensIdsByCollectionName;
    mapping(address => EnumerableSetUpgradeable.Bytes32Set)
        private collectionsByAddress;

    /// @notice Initial function
    /// @param _comment Address of our PageCommentMinter contract
    /// @param _bank Address of our PageBank contract
    /// @param _baseURL BaseURL of tokenURI, i.e. https://site.io/api/id=
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
        // bytes32 a = keccak256(abi.encodePacked(_msgSender(), collectionName));
        tokensIdsByCollectionName[_msgSender()][collectionName].push(tokenId);
        // tokensIdsByCollectionName[
        // keccak256(abi.encodePacked(_msgSender(), collectionName))
        // ].push(tokenId);
        // collectionsByAddress[_msgSender()].add(keccak256(abi.encodePacked(_msgSender(), collectionName)));
        collectionsByAddress[_msgSender()].add(collectionName);
        uint256 gas = gasBefore - gasleft();
        uint256 price = bank.processMint(_msgSender(), owner, gas);
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
        // uint256 gasBefore = gasleft();
        require(ownerOf(tokenId) == _msgSender(), "Allower only for owner");
        uint256 commentsReward = comment.calculateCommentsReward(
            address(this),
            tokenId
        );
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
        // uint256 gasAfter = gasBefore - gasleft();
        bank.processBurn(_msgSender(), 0, commentsReward);
        _safeBurn(tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param _from Approved or owner of token
    /// @param _to Receiver of token
    /// @param _tokenId Id of token
    /// @param data Stome data
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public override (IERC721Upgradeable, ERC721Upgradeable) {
        uint256 gasBefore = gasleft();
        require(_from != address(0), "Address can't be null");
        require(_to != address(0), "Address can't be null");
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721: transfer caller is not owner or approved"
        );
        _safeTransfer(_from, _to, _tokenId, data);
        uint256 amount = gasBefore - gasleft();
        bank.processMint(_from, _to, amount);
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

    function getTokensIdsByCollectionName(
        address account,
        bytes32 collectionName
    ) public view override returns (uint256[] memory tokenIds) {
        return tokensIdsByCollectionName[account][collectionName];
    }

    function getTokensURIsByCollectionName(
        address account,
        bytes32 collectionName
    ) public view override returns (string[] memory tokenURIs) {
        tokenURIs = new string[](
            tokensIdsByCollectionName[account][collectionName].length
        );
        for (
            uint256 i = 0;
            i < tokensIdsByCollectionName[account][collectionName].length;
            i++
        ) {
            tokenURIs[i] = tokenURI(
                tokensIdsByCollectionName[account][collectionName][i]
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
