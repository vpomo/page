// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "./interfaces/ICryptoPageCommentDeployer.sol";
import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageBank.sol";

contract PageNFT is ERC721URIStorageUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;
    IPageCommentDeployer private commentDeployer;
    IPageBank private bank;

    string private _name;
    string private _symbol;

    string public baseURL;
    address public treasury;
    uint256 public fee;

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => uint256) private pricesById;
    mapping(uint256 => address) private creatorById;

    /// @notice Initial function
    /// @param _commentDeployer Address of our PageCommentMinter contract
    /// @param _bank Address of our PageBank contract
    /// @param _baseURL BaseURL of tokenURI, i.e. https://ipfs.io/ipfs/
    /// @param _fee Percent of treasury fee (1000 is 10%; 100 is 1%; 10 is 0.1%)
    function initialize(
        address _commentDeployer,
        address _bank,
        string memory _baseURL,
        uint256 _fee
    ) public payable initializer {
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        // __Ownable_init_unchained();
        commentDeployer = IPageCommentDeployer(_commentDeployer);
        bank = IPageBank(_bank);
        baseURL = _baseURL;
        fee = _fee;
    }

    /// @notice Mint PAGE.NFT token
    /// @param _owner Address of token owner
    /// @param _tokenURI URI of token
    /// @return TokenId
    function safeMint(address _owner, string memory _tokenURI)
        public
        override
        returns (uint256)
    {
        uint256 gasBefore = gasleft();
        uint256 tokenId = _safeMint(_owner, _tokenURI);
        uint256 gasAfter = gasBefore - gasleft();
        uint256 price;
        if (_owner == msg.sender) {
            price = bank.mint(_owner, gasAfter);
        } else {
            price = bank.mintFor(msg.sender, _owner, gasAfter);
        }
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
    /// @param _tokenId Id of token
    function safeBurn(uint256 _tokenId) public override {
        uint256 gasBefore = gasleft();
        uint256 burnPrice;
        bool commentsExists = commentDeployer.isExists(address(this), _tokenId);
        if (commentsExists) {
            IPageComment commentContract = IPageComment(
                commentDeployer.getCommentContract(address(this), _tokenId)
            );
            IPageComment.Comment[] memory comments = commentContract
                .getComments();
            for (uint256 i = 0; i < comments.length; i++) {
                IPageComment.Comment memory comment = comments[i];
                burnPrice.add(comment.price.mul(2));
            }
        }
        uint256 gasAfter = gasBefore - gasleft();
        bank.burn(msg.sender, gasAfter, burnPrice);
        _safeBurn(_tokenId);
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
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner or approved"
        );
        _safeTransfer(from, to, tokenId, "");
        uint256 gasAfter = gasBefore - gasleft();
        bank.transferFrom(from, to, gasAfter);
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

    function tokenPrice(uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return pricesById[tokenId];
    }
}
