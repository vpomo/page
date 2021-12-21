// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PageToken is
    OwnableUpgradeable,
    AccessControlUpgradeable,
    ERC20Upgradeable
{
    using SafeMathUpgradeable for uint256;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    IUniswapV3Pool public usdtpagePool;
    IUniswapV3Pool public wethusdtPool;

    function initialize(address _treasury) public initializer {
        __Ownable_init();
        __ERC20_init("Crypto.Page", "PAGE");
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(_treasury, 5e25);
    }

    function setUSDTPAGEPool(address _usdtpagePool) public onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtpagePool);
    }

    function setWETHUSDTPool(address _wethusdtPool) public onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethusdtPool);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(to, amount);
    }

    function getWETHUSDTPrice() public view returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        uint256 price = ((sqrtPriceX96 * sqrtPriceX96) * (1e18 / 1e6)) /
            (192**2);
        return price;
    }

    function getUSDTPAGEPrice() external view returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = usdtpagePool.slot0();
        uint256 price = ((sqrtPriceX96 * sqrtPriceX96) * (1e18 / 1e6)) /
            (192**2);
        if (price > 100) {
            price = 100;
        }
        return price;
    }
}
