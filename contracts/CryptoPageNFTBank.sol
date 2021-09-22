// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "./interfaces/INFTMINT.sol";
import "./interfaces/IMINTER.sol";
import "./interfaces/IERCMINT.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract PageNFTBank {
    IERC721 public PAGE_NFT;
    IMINTER public PAGE_MINTER;
    IERCMINT public PAGE_TOKEN;
    constructor (address _PAGE_NFT, address _PAGE_MINTER) {
        PAGE_NFT = IERC721(_PAGE_NFT);
        PAGE_MINTER = IMINTER(_PAGE_MINTER);
        PAGE_TOKEN = IERCMINT(PAGE_MINTER.getPageToken());
    }

    function Buy(uint256 tokenId) public {
        require(PAGE_TOKEN.isEnoughOn(msg.sender, _buy), "Not enough tokens");
        require(address(this) == PAGE_NFT.ownerOf(tokenId), "only owner can call this function");
        PAGE_TOKEN.safeDeposit(msg.sender, address(this), _buy);
        PAGE_NFT.safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }
    function Sell(uint256 tokenId) public {
        // require(msg.sender == PAGE_MINTER.getAdmin(), "onlyAdmin: caller is not the admin");
        require(msg.sender == PAGE_NFT.ownerOf(tokenId), "only owner can call this function");
        PAGE_NFT.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        
        // MINT
    }

    modifier onlyAdmin() {        
        require(msg.sender == PAGE_MINTER.getAdmin(), "onlyAdmin: caller is not the admin");
        _;
    }

    uint256 private _sell = 1 ether;
    uint256 private _buy = 1 ether;
    function setBuyPrice(uint256 _price) public onlyAdmin() {
        _buy = _price;
    }
    function setSellPrice(uint256 _price) public onlyAdmin() {
        _sell = _price;
    }
    function getPrice() public view returns(uint256 sell, uint256 buy ) {
        /**********
        (uint256 id,
         address author,
         uint256 amount,
         bool xmint) = PAGE_NFT.getMinter("NFTBANK");
         **********/

         // setMinter("NFTBANK", address(PAGE_NFT), 1 ** 18, true);

        sell = _sell;
        buy = _buy;
    }
    
}
