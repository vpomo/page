// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// IERC20

interface IERCMINT {
    function mint( address to, uint256 amount ) external ;
    function xburn(address from, uint256 amount) external ;
    function burn( uint256 amount ) external ;

    function safeDeposit(address from, address to, uint256 amount) external ;
    function safeWithdraw(address from, address to, uint256 amount) external ;
}
