// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableMapUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./interfaces/ICryptoPageComment.sol";
import "./interfaces/ICryptoPageCommentDeployer.sol";
import "./interfaces/ICryptoPageToken.sol";
import "./interfaces/ICryptoPageBank.sol";
import "./CryptoPageComment.sol";

contract PageCommentDeployer is OwnableUpgradeable, IPageCommentDeployer {
    using EnumerableMapUpgradeable for EnumerableMapUpgradeable.UintToAddressMap;
    using SafeMathUpgradeable for uint256;

    mapping(address => EnumerableMapUpgradeable.UintToAddressMap)
        private commentsByERC721;

    IPageToken public token;
    IPageBank public bank;

    /// @notice Initial function
    /// @param _token Address of our PageToken contract
    /// @param _bank Address of our PageBank contract
    function initialize(address _token, address _bank)
        public
        payable
        override
        initializer
    {
        __Ownable_init();
        token = IPageToken(_token);
        bank = IPageBank(_bank);
    }

    /// @notice Return true if PageComment contract exists
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @return Boolean
    function _exists(address _nft, uint256 _tokenId)
        private
        view
        returns (bool)
    {
        return commentsByERC721[_nft].contains(_tokenId);
    }

    /// @notice Return PageComment instance if PageComment contract exists
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @return PageComment
    function _get(address _nft, uint256 _tokenId)
        private
        view
        returns (address)
    {
        return commentsByERC721[_nft].get(_tokenId);
    }

    /// @notice Set PageComment contract to commentsByERC721
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @return PageComment
    function _set(address _nft, uint256 _tokenId)
        private
        returns (address)
    {
        PageComment comment = new PageComment();
        commentsByERC721[_nft].set(_tokenId, address(comment));
        return address(comment);
    }

    /// @notice Return true if PageComment contract exists
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @return Boolean
    function isExists(address _nft, uint256 _tokenId)
        public
        view
        override
        returns (bool)
    {
        return _exists(_nft, _tokenId);
    }

    /// @notice Create comment for any ERC721 Token
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @param _author Author of comment
    /// @param _text Text of comment
    /// @param _like Positive or negative reaction to comment
    function createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) public override {
        uint256 gasBefore = gasleft();
        uint256 commentId = _createComment(
            _nft,
            _tokenId,
            _author,
            _text,
            _like
        );
        uint256 gasAfter = gasleft() - gasBefore;
        uint256 price = bank.comment(_msgSender(), _author, gasAfter);
        IPageComment(_get(_nft, _tokenId)).setPrice(commentId, price);
    }

    /// @notice Create comment for any ERC721 Token
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @param _author Author of comment
    /// @param _text Text of comment
    /// @param _like Positive or negative reaction to comment
    function _createComment(
        address _nft,
        uint256 _tokenId,
        address _author,
        string memory _text,
        bool _like
    ) private returns (uint256) {
        bool exists = _exists(_nft, _tokenId);
        if (exists) {
            return
                uint256(
                    IPageComment(_get(_nft, _tokenId)).setComment(
                        _author,
                        _text,
                        _like
                    )
                );
        } else {
            return
                uint256(
                    IPageComment(_set(_nft, _tokenId)).setComment(
                        _author,
                        _text,
                        _like
                    )
                );
        }
    }

    /// @notice Return PageComment contract
    /// @param _nft Address of ERC721 Contract
    /// @param _tokenId Id of ERC721 Token
    /// @return PageComment
    function getCommentContract(address _nft, uint256 _tokenId)
        public
        view
        override
        returns (address)
    {
        require(_exists(_nft, _tokenId), "NFT contract does not exist");
        return _get(_nft, _tokenId);
    }
}
