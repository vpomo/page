// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CryptoPageToken.sol";
import "./CryptoPageTokenMinter.sol";
import "./CryptoPageNFT.sol";
import "./CryptoPageNFTMinter.sol";

contract PageAdmin is Ownable {
    address public treasury;
    PageTokenMinter public tokenMinter;
    PageNFTMinter public nftMinter;

    constructor(
        address _treasury,
        PageTokenMinter _tokenMinter,
        PageNFTMinter _nftMinter
    ) {
        treasury = _treasury;
        tokenMinter = _tokenMinter;
        nftMinter = _nftMinter;
    }

    function setMintFee(uint256 _percent) public onlyOwner {
        nftMinter.setMintFee(_percent);
    }

    function setBurnFee(uint256 _percent) public onlyOwner {
        nftMinter.setBurnFee(_percent);
    }

    function setTreasury(address _treasury) public onlyOwner {
        nftMinter.setTreasury(_treasury);
    }
}
