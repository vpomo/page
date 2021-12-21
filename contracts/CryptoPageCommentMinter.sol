// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./CryptoPageComment.sol";
import "./CryptoPageToken.sol";

contract PageCommentMinter is OwnableUpgradeable {
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;
    using SafeMathUpgradeable for uint256;

    mapping(address => EnumerableMapUpgradeable.UintToAddressMap)
        private commentsByERC721;

    PageToken public token;
    address public treasury;

    function initialize(address _treasury, address _token)
        public
        payable
        initializer
    {
        __Ownable_init();
        treasury = _treasury;
        token = PageToken(_token);
    }

    function _exists(address _nft, uint256 _tokenId)
        private
        view
        returns (bool)
    {
        return commentsByERC721[_nft].contains(_tokenId);
    }

    function _get(address _nft, uint256 _tokenId)
        private
        view
        returns (PageComment)
    {
        return PageComment(commentsByERC721[_nft].get(_tokenId));
    }

    function _set(address _nft, uint256 _tokenId)
        private
        returns (PageComment)
    {
        PageComment comment = new PageComment();
        commentsByERC721[_nft].set(_tokenId, address(comment));
        return comment;
    }

    function isExists(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        treasury = _treasury;
    }

    function createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) public {
        uint256 amount = gasleft()
            .mul(tx.gasprice)
            .mul(token.getWETHUSDTPrice())
            .mul(token.getUSDTPAGEPrice())
            .div(10000)
            .mul(8000);
        bool exists = _exists(_nft, _tokenId);
        if (exists) {
            _get(_nft, _tokenId).createComment(_author, _text, _like);
        } else {
            _set(_nft, _tokenId).createComment(_author, _text, _like);
        }
        uint256 accountAmount = amount.div(10000).mul(9000);
        uint256 treasuryAmount = amount.sub(accountAmount);
        IERC721Upgradeable nft = IERC721Upgradeable(_nft);

        token.mint(nft.ownerOf(_tokenId), accountAmount);
        token.mint(treasury, treasuryAmount);
    }

    function getContract(address _nft, uint256 _tokenId)
        public
        view
        returns (PageComment)
    {
        require(_exists(_nft, _tokenId), "NFT contract does not exist");
        return _get(_nft, _tokenId);
    }

    function getTreasury() public view returns (address) {
        return treasury;
    }
}
