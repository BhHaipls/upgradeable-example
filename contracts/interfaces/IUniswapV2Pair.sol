// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

/// @title IUniswapV2Pair
/// @author Applicature
/// @notice There is an interface to UniswapV2Pair to call getReserves() from Proccesors
interface IUniswapV2Pair {
    /// @notice Get reserves of uniswap pair tokens
    /// @return reserve0 Store reserve to token0
    /// @return reserve1 Store reserve to token1
    /// @return blockTimestampLast Last updated time
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    /// @notice Get address of first token in uniswap pair
    /// @return Token address
    function token0() external view returns (address);
}
