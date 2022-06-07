// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IPageOracle {

    function version() external pure returns (string memory);

    function setTwapIntervals(uint32 newTwapInterval) external;

    function changeStablePriceStatus() external;

    function setStablePrice(uint256 newPrice) external;

    function getFromPageToWethPrice() external view returns (uint256 price);

    function getFromWethToPageAmount(uint256 wethAmountIn) external view returns (uint256 pageAmountOut);

}
