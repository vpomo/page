// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./CryptoPageTokenMinter.sol";
import "./CryptoPageNFT.sol";
import "./CryptoPageCommentMinter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PageNFTMinter is Ownable {
    PageCommentMinter private commentMinter;
    PageTokenMinter private tokenMinter;
    PageNFT private nft;

    address private treasury;
    uint256 private mintFee = 1000; // 100 is 1% || 10000 is 100%
    uint256 private burnFee = 0; // 100 is 1% || 10000 is 100%

    constructor(
        address _treasury,
        PageTokenMinter _tokenMinter,
        PageNFT _nft,
        PageCommentMinter _commentMinter
    ) {
        treasury = _treasury;
        tokenMinter = _tokenMinter;
        commentMinter = _commentMinter;
        nft = _nft;
    }

    function safeMint(string memory _tokenURI, bool _commentActive)
        public
        returns (uint256)
    {
        uint256 amount = 9000000000000000000;
        uint256 fee = 1000000000000000000;
        uint256 tokenId = nft.mint(msg.sender, _tokenURI);
        if (_commentActive) {
            commentMinter.activateComment(address(nft), tokenId);
        }
        tokenMinter.mint(msg.sender, amount);
        tokenMinter.mint(treasury, fee);
        return (tokenId);
    }

    function burn(uint256 _tokenId) public {
        require(
            nft.ownerOf(_tokenId) == msg.sender,
            "It's possible only for owner"
        );
        tokenMinter.burn(msg.sender, 10);
        nft.burn(_tokenId);
    }

    function setTreasury(address _treasury) public onlyOwner {
        require(_treasury != address(0), "setTreasuryAddress: is zero address");
        treasury = _treasury;
    }

    function setBurnFee(uint256 _percent) public onlyOwner {
        require(_percent >= 10, "setBurnFee: minimum burn fee percent is 0.1%");
        require(
            _percent <= 3000,
            "setBurnFee: maximum burn fee percent is 30%"
        );
        burnFee = _percent;
    }

    function setMintFee(uint256 _percent) public onlyOwner {
        require(_percent >= 10, "setMintFee: minimum mint fee percent is 0.1%");
        require(
            _percent <= 3000,
            "setMintFee: maximum mint fee percent is 30%"
        );
        mintFee = _percent;
    }

    function getTreasury() public view returns (address) {
        return treasury;
    }

    function getMintFee() public view returns (uint256) {
        return mintFee;
    }

    function getBurnFee() public view returns (uint256) {
        return burnFee;
    }
}
