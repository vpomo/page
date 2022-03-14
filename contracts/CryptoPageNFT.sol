// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";

import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageBank.sol";

/// @title Contract of PAGE.NFT token
/// @author Crypto.Page Team
/// @notice
/// @dev //https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/master/contracts
contract PageNFT is Initializable, OwnableUpgradeable, ERC721URIStorageUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.Bytes32Set;

    CountersUpgradeable.Counter public _tokenIdCounter;
    IPageComment public comment;
    IPageBank public bank;
    address public community;

    string private _name;
    string private _symbol;
    string public baseURL;

    mapping(uint256 => address) private creatorById;

    modifier onlyCommunity() {
        require(_msgSender() == community, "PageNFT: not community");
        _;
    }

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

    function setCommunity(address communityContract) external onlyOwner {
        require(communityContract != address(0), "Address can't be null");
        community = communityContract;
    }

    /// @notice Mint PAGE.NFT token
    /// @param owner Address of token owner
    /// @param tokenURI URI of token
    function mint(address owner, uint256 communityId) public onlyCommunity override returns (uint256) {
        uint256 gasBefore = gasleft();
        require(owner != address(0), "Address can't be null");
        return _mint(_owner, _tokenURI);
    }

    /// @notice Burn PAGE.NFT token
    /// @param tokenId Id of token
    function burn(uint256 tokenId) public onlyCommunity override {
        // Check the amount of gas before counting awards for comments
        // uint256 gasBefore = gasleft();
        require(ownerOf(tokenId) == _msgSender(), "Allower only for owner");
        uint256 commentsReward = comment.calculateCommentsReward(
            address(this),
            tokenId
        );
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
        bank.mintTokenForNewPost(_from, _to, amount);
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
}
