// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/contracts/libraries/FixedPoint96.sol";
import "@uniswap/contracts/libraries/FullMath.sol";
import "@uniswap/contracts/libraries/TickMath.sol";


contract PageOracle is Initializable, OwnableUpgradeable {

    using FullMath for uint256;

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _treasury Address of our treasury
     * @param _bank Address of our PageBank contract
     */
    function initialize() public initializer {
        __Ownable_init();
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() external pure returns (string memory) {
        return "1";
    }

    /**
     * @dev Returns the price in fixed point 96 from the square of the price in fixed point 96
     *
     * @param _sqrtPriceX96 The square of the price in fixed point 96
     * @return priceX96 The price in fixed point 96
     */
    function _getPriceX96FromSqrtPriceX96(uint160 _sqrtPriceX96) internal pure returns (uint256 priceX96) {
        return FullMath.mulDiv(_sqrtPriceX96, _sqrtPriceX96, FixedPoint96.Q96);
    }
}
