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

    IUniswapV3Pool public pool;

    constructor(address _treasury) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(_treasury, 1e25);
    }

    function setPool(address _pool) public onlyOwner {
        pool = IUniswapV3Pool(_pool);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(address to, uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(to, amount);
    }

    function getPrice() external view returns (uint256) {
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        uint256 price = uint256(sqrtPriceX96).mul(uint256(sqrtPriceX96)) >>
            (96 * 2);
        if (price == 0) {
            return 1;
        }
        return price;
    }
}
