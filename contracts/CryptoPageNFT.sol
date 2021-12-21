// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./CryptoPageCommentMinter.sol";
import "./CryptoPageComment.sol";
import "./CryptoPageToken.sol";

contract PageNFT is OwnableUpgradeable, ERC721URIStorageUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    using SafeMathUpgradeable for uint256;

    CountersUpgradeable.Counter private _tokenIdCounter;
    PageToken private token;
    PageCommentMinter private commentMinter;

    string public baseURL = "https://ipfs.io/ipfs/";
    address public treasury;
    uint256 public fee = 1000;

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => uint256) private pricesById;
    mapping(uint256 => address) private creatorById;

    function initialize(
        address _treasury,
        address _token,
        address _commentMinter
    ) public payable initializer {
        __ERC721_init("Crypto.Page NFT", "PAGE.NFT");
        __Ownable_init_unchained();
        treasury = _treasury;
        token = PageToken(_token);
        commentMinter = PageCommentMinter(_commentMinter);
    }

    function safeMint(address _owner, string memory _tokenURI)
        public
        returns (uint256)
    {
        uint256 amount = gasleft()
            .mul(tx.gasprice)
            .mul(token.getWETHUSDTPrice())
            .mul(token.getUSDTPAGEPrice())
            .div(10000)
            .mul(8000);
        uint256 tokenId = _mint(_owner, _tokenURI);
        uint256 treasuryAmount = amount.div(10000).mul(fee);
        uint256 ownerAmount = amount.sub(treasuryAmount);
        pricesById[tokenId] = amount;

        token.mint(treasury, treasuryAmount);
        if (msg.sender == _owner) {
            token.mint(_owner, ownerAmount);
        } else {
            uint256 senderAmount = ownerAmount.div(2);
            token.mint(_owner, senderAmount);
            token.mint(msg.sender, senderAmount);
        }

        return (tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        uint256 amount = gasleft()
            .mul(tx.gasprice)
            .mul(token.getWETHUSDTPrice())
            .mul(token.getUSDTPAGEPrice())
            .div(10000)
            .mul(8000);

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner or approved"
        );
        uint256 accountAmount = amount.div(10000).mul(3000);
        uint256 treasuryAmount = amount.div(10000).mul(1000);
        _transfer(from, to, tokenId);
        token.mint(msg.sender, accountAmount);
        token.mint(creatorById[tokenId], accountAmount);
        token.mint(treasury, treasuryAmount);
    }

    function burn(uint256 _tokenId) public {
        uint256 price = token.getWETHUSDTPrice().mul(token.getUSDTPAGEPrice());
        uint256 burnPrice = gasleft()
            .mul(tx.gasprice)
            .mul(price)
            .div(10000)
            .mul(8000);
        require(
            ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        bool commentsExists = commentMinter.isExists(address(this), _tokenId);
        if (commentsExists) {
            PageComment commentContract = commentMinter.getContract(
                address(this),
                _tokenId
            );
            PageComment.Comment[] memory comments = commentContract
                .getComments();
            for (uint256 i = 0; i < comments.length; i++) {
                PageComment.Comment memory comment = comments[i];
                burnPrice.add(comment.price.mul(2).mul(price));
            }
        }
        require(
            token.balanceOf(msg.sender) >= burnPrice,
            "not enought balance"
        );
        _burn(_tokenId);
        token.burn(msg.sender, burnPrice);
    }

    function _mint(address owner, string memory _tokenURI)
        private
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        creatorById[tokenId] = owner;
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return tokenId;
    }

    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasury: is zero address");
        treasury = _treasury;
    }

    function setFee(uint256 _percent) public onlyOwner {
        require(_percent >= 10, "setMintFee: minimum mint fee percent is 0.1%");
        require(
            _percent <= 3000,
            "setMintFee: maximum mint fee percent is 30%"
        );
        fee = _percent;
    }

    function tokenPrice(uint256 tokenId) public view returns (uint256) {
        require(tokenId <= _tokenIdCounter.current(), "No token with this Id");
        return pricesById[tokenId];
    }

    function getFee() public view returns (uint256) {
        return fee;
    }

    function getTreasury() public view returns (address) {
        return treasury;
    }
}
