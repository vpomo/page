// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./CryptoPageComment.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PageCommentMinter {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    mapping(address => EnumerableMap.UintToAddressMap) private commentsByERC721;

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
        PageComment comment = new PageComment();
        commentsByERC721[_nft].set(_tokenId, address(comment));
        return comment; // new PageComment();
    }

    function activated(address _nft, uint256 _tokenId)
        public
        view
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    function activateComment(address _nft, uint256 _tokenId) public {
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
