// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ISAFE {
    function isSafe(address _safe) external view returns (bool);

    function addSafe(address[] calldata _safe) external;

    function removeSafe(address _safe) external;

    function changeSafe(address _from, address _to) external;
}
