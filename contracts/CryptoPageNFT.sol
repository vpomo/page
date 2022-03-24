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
    IPageBank public bank;
    address public community;

    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    modifier onlyCommunity() {
        require(_msgSender() == community, "PageNFT: not community");
        _;
    }

    /// @notice Initial function
    /// @param _bank Address of our PageBank contract
    /// @param _baseURL BaseURL of tokenURI, i.e. https://site.io/api/id=
    function initialize(
        address _bank,
        string memory _baseURL
    ) public payable initializer {
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        bank = IPageBank(_bank);
        _baseTokenURI = _baseURL;
    }

    function version() public view returns (string memory) {
        return "1";
    }

    function setCommunity(address communityContract) external onlyOwner {
        require(communityContract != address(0), "Address can't be null");
        community = communityContract;
    }

    function setBaseTokenURI(string memory baseTokenURI) public onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    /// @notice Mint PAGE.NFT token
    /// @param owner Address of token owner
    /// @param tokenURI URI of token
    function mint(address owner) public override onlyCommunity returns (uint256) {
        require(owner != address(0), "Address can't be null");
        return _mint(_owner);
    }

    /// @notice Burn PAGE.NFT token
    /// @param tokenId Id of token
    function burn(uint256 tokenId) public override onlyCommunity {
        _burn(_tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param _from Approved or owner of token
    /// @param _to Receiver of token
    /// @param _tokenId Id of token
    /// @param data Stome data
    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(super.getApproved(_tokenId) != _to, "Address can't be approved");
        super.transferFrom(_from, _to, _tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param _from Approved or owner of token
    /// @param _to Receiver of token
    /// @param _tokenId Id of token
    /// @param data Stome data
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(super.getApproved(_tokenId) != _to, "Address can't be approved");
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param _from Approved or owner of token
    /// @param _to Receiver of token
    /// @param _tokenId Id of token
    /// @param data Stome data
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
        require(super.getApproved(_tokenId) != _to, "Address can't be approved");
        super.safeTransferFrom(_from, _to, _tokenId, _data);
    }

    function tokensOfOwner(address user) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(user);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory output = new uint256[](tokenCount);
            for (uint256 index = 0; index < tokenCount; index++) {
                output[index] = tokenOfOwnerByIndex(user, index);
            }
            return output;
        }
    }

    /// @notice Mint PAGE.NFT token
    /// @param _owner Address of token owner
    /// @param _tokenURI URI of token
    /// @return TokenId
    function _mint(address _owner) private returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(_owner, tokenId);
        _tokenIdCounter.increment();
        return tokenId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}
