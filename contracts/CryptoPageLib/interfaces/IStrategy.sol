// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IStrategy {
    function getJson(string memory _function, string memory _values) external view returns (string memory);
    function sendJson(string memory _function, string memory _values) external;    
}
