// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";

import "./interfaces/ICryptoPageNFT.sol";
import "./interfaces/ICryptoPageBank.sol";

/// @title Contract of PAGE.NFT token
/// @author Crypto.Page Team
/// @notice
/// @dev //https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/master/contracts
contract PageNFT is OwnableUpgradeable, ERC721EnumerableUpgradeable, IPageNFT {
    using CountersUpgradeable for CountersUpgradeable.Counter;

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
        __Ownable_init();
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        bank = IPageBank(_bank);
        _baseTokenURI = _baseURL;
    }

    function version() public pure returns (string memory) {
        return "1";
    }

    function setCommunity(address communityContract) external override onlyOwner {
        require(communityContract != address(0), "Address can't be null");
        community = communityContract;
    }

    function setBaseTokenURI(string memory baseTokenURI) external override onlyOwner {
        _baseTokenURI = baseTokenURI;
    }

    /// @notice Mint PAGE.NFT token
    /// @param owner Address of token owner
    function mint(address owner) external override onlyCommunity returns (uint256) {
        require(owner != address(0), "Address can't be null");
        return _mint(owner);
    }

    /// @notice Burn PAGE.NFT token
    /// @param tokenId Id of token
    function burn(uint256 tokenId) external override onlyCommunity {
        _burn(tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param from Approved or owner of token
    /// @param to Receiver of token
    /// @param tokenId Id of token
    function transferFrom(address from, address to, uint256 tokenId) public virtual
    override(ERC721Upgradeable, IERC721Upgradeable) {
        require(super.getApproved(tokenId) != to, "Address can't be approved");
        super.transferFrom(from, to, tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param from Approved or owner of token
    /// @param to Receiver of token
    /// @param tokenId Id of token
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual
    override(ERC721Upgradeable, IERC721Upgradeable) {
        require(super.getApproved(tokenId) != to, "Address can't be approved");
        super.safeTransferFrom(from, to, tokenId);
    }

    /// @notice Transfer PAGE.NFT token
    /// @param from Approved or owner of token
    /// @param to Receiver of token
    /// @param tokenId Id of token
    /// @param data Stome data
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public
    override(ERC721Upgradeable, IERC721Upgradeable) {
        require(super.getApproved(tokenId) != to, "Address can't be approved");
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function tokensOfOwner(address user) external override view returns (uint256[] memory) {
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
    /// @param owner Address of token owner
    /// @return tokenId ID for minted token
    function _mint(address owner) private returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _mint(owner, tokenId);
        _tokenIdCounter.increment();
        return tokenId;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}
