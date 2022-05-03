// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC1155/IERC1155Upgradeable.sol";

interface IPageUserRateToken is IERC1155Upgradeable {

    function version() external pure returns (string memory);

    function setCommunity(address communityContract) external;

    function totalSupply(uint256 id) external view returns (uint256);

    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;
}
