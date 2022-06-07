// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/OwnableUpgradeable.sol";
import "@uniswap/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/contracts/libraries/FixedPoint96.sol";

import "../interfaces/ICryptoPageOracle.sol";
import "../libraries/FullMath.sol";
import "../libraries/TickMath.sol";

contract PageOracle is Initializable, OwnableUpgradeable, IPageOracle {

    using FullMath for uint256;

    uint32 public pageTwapInterval; // The interval for the Time-Weighted Average Price for PAGE_TOKEN/WETH9 pool.

    address public PAGE_TOKEN; // The PAGE token address.

    IUniswapV3Pool public pool;
    bool public isStablePrice;
    uint256 public stablePrice;

    event SetTwapIntervals(uint32 oldTwapInterval, uint32 newTwapInterval);
    event ChangeStablePriceStatus(bool newStatus);
    event SetStablePrice(uint256 oldPrice, uint256 newPrice);

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
    function version() external pure override returns (string memory) {
        return "1";
    }

    /**
     * @dev Sets TWAP intervals
     *
     * @param newTwapInterval The new `pageTwapInterval`.
     */
    function setTwapIntervals(uint32 newTwapInterval) external override onlyOwner {
        require(newTwapInterval >= 15 minutes, "PageOracle: TWAP too short");
        emit SetTwapIntervals(pageTwapInterval, newTwapInterval);
        pageTwapInterval = newTwapInterval;
    }

    /**
    * @dev Changes status for the stable price
     *
     */
    function changeStablePriceStatus() external override onlyOwner {
        isStablePrice = !isStablePrice;
        emit ChangeStablePriceStatus(isStablePrice);
    }

    /**
     * @dev Setting a new stable price value
     *
     * @param newPrice The new value of the stable price.
     */
    function setStablePrice(uint256 newPrice) external override onlyOwner {
        require(newPrice > 0 && newPrice != stablePrice, "PageOracle: wrong new price");
        emit SetStablePrice(stablePrice, newPrice);
        stablePrice = newPrice;
    }

    /**
     * @dev Returns PAGE / WETH price from UniswapV3
     */
    function getFromPageToWethPrice() public view override returns (uint256 price) {
        price = isStablePrice ? stablePrice : getAmountWETHFromPage(1e18);
    }

    /**
     * @dev Returns WETH / Page amount
     */
    function getFromWethToPageAmount(uint256 wethAmountIn) external view override returns (uint256 pageAmountOut) {
        uint256 price = getFromPageToWethPrice();
        require(price > 0, "PageOracle: wrong price");
        pageAmountOut = wethAmountIn * 1e18 / price;
    }

    /**
     * @dev Makes TWAP a request to the pool and calculates the amount of ether
     *
     * @param pageAmountIn Amount of Page tokens
     * @return wethAmountOut Amount of WETH tokens
     */
    function getAmountWETHFromPage(uint256 pageAmountIn) internal view returns (uint256 wethAmountOut) {
        uint32[] memory pageSecondsAgo = new uint32[](2);
        pageSecondsAgo[0] = pageTwapInterval;
        pageSecondsAgo[1] = 0;

        (int56[] memory tickCumulatives1, ) = pool.observe(pageSecondsAgo);

        // Ticks (imprecise as it's an integer) to price.
        uint160 sqrtPriceX961 = TickMath.getSqrtRatioAtTick(
            int24((tickCumulatives1[1] - tickCumulatives1[0]) / int24(uint24(pageTwapInterval)))
        );

        // Computation depends on the position of token in pool.
        if (pool.token0() == PAGE_TOKEN) {
            wethAmountOut = pageAmountIn.mulDiv(
                _getPriceX96FromSqrtPriceX96(sqrtPriceX961),
                FixedPoint96.Q96
            );
        } else {
            wethAmountOut = pageAmountIn.mulDiv(
                FixedPoint96.Q96,
                _getPriceX96FromSqrtPriceX96(sqrtPriceX961)
            );
        }
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
