
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMINTER {
    function _amount_mint(string memory _key, uint256 _address_count) external view returns (uint256 amount_each, uint256 fee);
    function mint(string memory _key, address [] memory _to) external;
    function mintX(string memory _key, address [] memory _to, uint _multiplier) external;
    function burn( uint256 amount ) external ;
    function removeMinter(string memory _key) external;
    function setMinter(string memory _key, address _account, uint256 _pageamount, bool _xmint) external;
    function getMinter(string memory _key) external view returns (
        uint256 id,
        address author,
        uint256 amount,
        bool xmint);
}
