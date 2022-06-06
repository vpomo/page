// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/contracts/libraries/FixedPoint96.sol";

import "../libraries/FullMath.sol";
import "../libraries/TickMath.sol";

contract PageOracle is Initializable, OwnableUpgradeable {

    using FullMath for uint256;

    uint256 public constant ONE_PERCENT = 100; // 1% in basis points.
    uint256 public constant MAX_BASIS_POINTS = 10_000; // 100% in basis points.

    uint32 public pageTwapInterval; // The interval for the Time-Weighted Average Price for PAGE_TOKEN/WETH9 pool.

    address public PAGE_TOKEN; // The PAGE token address.

    IUniswapV3Pool public pool;

    event TwapIntervalsSet(uint32 oldTwapInterval, uint32 newTwapInterval);

    /// @notice Thrown when a TWAP interval is too short.
    error TwapTooShort();

    /**
     * @dev Makes the initialization of the initial values for the smart contract
     *
     * @param _token Address of our PAGE token contract
     * @param _pool Address of our pool contract
     */
    function initialize(address _token, address _pool) public initializer {
        __Ownable_init();
        require(_token != address(0), "PageOracle: wrong address");
        require(_pool != address(0), "PageOracle: wrong address");

        PAGE_TOKEN = _token;
        pool = IUniswapV3Pool(_pool);
        pageTwapInterval = 15 minutes;
    }

    /**
     * @dev Returns the smart contract version
     *
     */
    function version() external pure returns (string memory) {
        return "1";
    }

    /**
     * @dev Sets TWAP intervals
     *
     * @param newTwapInterval The new `pageTwapInterval`.
     */
    function setTwapIntervals(uint32 newTwapInterval) external onlyOwner {
        if (newTwapInterval < 15 minutes)
            revert TwapTooShort();
        emit TwapIntervalsSet(pageTwapInterval, newTwapInterval);
        pageTwapInterval = newTwapInterval;
    }

    function getAmountOutMinimum(uint256 _amountIn) internal view returns (uint256 expectedAmountOutMinimum)
    {
        uint32[] memory pageSecondsAgo = new uint32[](2);
        pageSecondsAgo[0] = pageTwapInterval;
        pageSecondsAgo[1] = 0;

        (int56[] memory tickCumulatives1, ) = pool.observe(pageSecondsAgo);

        // For the pair token0/token1 -> 1.0001 * readingTick = price = token1 / token0
        // So token1 = price * token0

        // Ticks (imprecise as it's an integer) to price.
        uint160 sqrtPriceX961 = TickMath.getSqrtRatioAtTick(
            int24((tickCumulatives1[1] - tickCumulatives1[0]) / int24(uint24(pageTwapInterval)))
        );

        // Computation depends on the position of token in pool.
        if (pool.token0() == PAGE_TOKEN) {
            expectedAmountOutMinimum = _amountIn.mulDiv(
                _getPriceX96FromSqrtPriceX96(sqrtPriceX961),
                FixedPoint96.Q96
            );
        } else {
            expectedAmountOutMinimum = _amountIn.mulDiv(
                FixedPoint96.Q96,
                _getPriceX96FromSqrtPriceX96(sqrtPriceX961)
            );
        }

        // Max slippage of 1% for the trade.
        expectedAmountOutMinimum = (expectedAmountOutMinimum * (MAX_BASIS_POINTS - ONE_PERCENT)) / MAX_BASIS_POINTS;
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
