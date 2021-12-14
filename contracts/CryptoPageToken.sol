// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PageToken is ERC20("PageToken", "PAGE"), AccessControl, Ownable {
    using SafeMath for uint256;

    bytes32 private constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 private constant BURNER_ROLE = keccak256("BURNER_ROLE");

    IUniswapV3Pool public usdtpagePool;
    IUniswapV3Pool public wethusdtPool;

    constructor(address _treasury) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(_treasury, 1e25);
    }

    function setUSDTPAGEPool(address _usdtPool) public onlyOwner {
        usdtpagePool = IUniswapV3Pool(_usdtPool);
    }

    function setWETHUSDTPool(address _wethPool) public onlyOwner {
        wethusdtPool = IUniswapV3Pool(_wethPool);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(to, amount);
    }

    function getWETHUSDTPrice() external view returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = wethusdtPool.slot0();
        uint256 price = (sqrtPriceX96 / ( 2 ** 96 )) **2;
        // if (price > 400000) {
            // price = 400000;
        // }
        return price;
    }

    function getUSDTPAGEPrice() external view returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = usdtpagePool.slot0();
        uint256 price =  (sqrtPriceX96 / ( 2 ** 96 )) **2;
        if (price > 100) {
            price = 100;
        }
        return price;
    }
}
