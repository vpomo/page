// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./CryptoPageComment.sol";
import "./CryptoPageToken.sol";
import "./CryptoPageNFT.sol";

contract PageCommentMinter {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    mapping(address => EnumerableMap.UintToAddressMap) private commentsByERC721;

    PageToken public token;

    address public treasury;
    uint256 public amount = 3000000000000000000;
    uint256 public fee = 1000000000000000000;

    constructor(address _treasury, PageToken _token) {
        treasury = _treasury;
        token = _token;
    }

    function _exists(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return commentsByERC721[_nft].contains(_tokenId);
    }

    function _get(address _nft, uint256 _tokenId)
        public
        view
        returns (PageComment)
    {
        return PageComment(commentsByERC721[_nft].get(_tokenId));
    }

    function _set(address _nft, uint256 _tokenId) public returns (PageComment) {
        IERC721 nft = IERC721(_nft);
        address owner = nft.ownerOf(_tokenId);
        PageComment comment = new PageComment(owner);
        commentsByERC721[_nft].set(_tokenId, address(comment));
        token.mint(owner, amount);
        token.mint(treasury, fee);
        return comment; // new PageComment();
    }

    function activated(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    function hasComments(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    function getContract(address _nft, uint256 _tokenId)
        public
        view
        returns (PageComment)
    {
        require(_exists(_nft, _tokenId), "NFT contract does not exist");
        return _get(_nft, _tokenId);
    }

    function activateComments(address _nft, uint256 _tokenId) public {
        _set(_nft, _tokenId);
    }

    function createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) public {
        bool exists = _exists(_nft, _tokenId);
        if (exists) {
            _get(_nft, _tokenId).createComment(_author, _text, _like);
        } else {
            _set(_nft, _tokenId).createComment(_author, _text, _like);
        }
    }
}
