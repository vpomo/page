// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CryptoPageToken.sol";
import "./CryptoPageNFT.sol";

contract PageAdmin is Ownable {
    address public treasury;
    PageToken public token;
    PageNFT public nft;

    constructor(
        address _treasury,
        PageToken _token,
        PageNFT _nft
    ) {
        treasury = _treasury;
        token = _token;
        nft = _nft;
    }

    function setMintFee(uint256 _percent) public onlyOwner {
        nft.setMintFee(_percent);
    }

    function setBurnFee(uint256 _percent) public onlyOwner {
        nft.setBurnFee(_percent);
    }

    function setTreasury(address _treasury) public onlyOwner {
        nft.setTreasury(_treasury);
    }
}
