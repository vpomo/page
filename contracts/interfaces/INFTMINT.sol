// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface INFTMINT {  
    function burn( uint256 amount ) external ;
    function setBaseURL( string memory url ) external ;
    function getBaseURL() external view returns (string memory);
    function creatorOf( uint256 tokenId ) external view returns (address);
}
