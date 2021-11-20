// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CryptoPageNFTMinter.sol";
import "./CryptoPageTokenMinter.sol";
import "./CryptoPageComment.sol";

contract PageNFT is ERC721("Page NFT", "PAGE-NFT"), ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    IERC20 private pageToken;

    string private baseURL = "https://ipfs.io/ipfs/";

    mapping(uint256 => address) private commentsById;
    mapping(uint256 => address) private creatorById;

    function mint(address owner, string memory _tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        uint256 tokenId = _tokenIdCounter.current();
        creatorById[tokenId] = owner;
        _safeMint(owner, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _tokenIdCounter.increment();
        return tokenId;
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function burn(uint256 _tokenId) public onlyOwner {
        _burn(_tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return string(abi.encodePacked(getBaseURL(), super.tokenURI(tokenId)));
    }

    function getBaseURL() public view returns (string memory) {
        return baseURL;
    }
}
