
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMINTER {
    function _amount_mint(string memory _key, uint256 _address_count) external view returns (uint256 amount_each, uint256 fee);
    function mint(string memory _key, address [] memory _to) external;
    function mint1(string memory _key, address _to) external;
    function mint2(string memory _key, address _to1, address _to2) external;
    function mint3(string memory _key, address _to1, address _to2, address _to3) external;
    function mintX(string memory _key, address [] memory _to, uint _multiplier) external;
    function burn( address from, uint256 amount  ) external ;
    function removeMinter(string memory _key) external;
    function setMinter(string memory _key, address _account, uint256 _pageamount, bool _xmint) external;
    function getMinter(string memory _key) external view returns (
        uint256 id,
        address author,
        uint256 amount,
        bool xmint);
    // Burn NFT PRICE
    function setBurnNFT(uint256 _cost) external;
    function getBurnNFT() external view returns (uint256);
    function getAdmin() external view returns (address);
    function getPageToken() external view returns (address);
}
