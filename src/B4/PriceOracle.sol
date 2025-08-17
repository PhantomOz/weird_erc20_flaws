// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that includes the `decimals` function.
interface IERC20 {
    function decimals() external view returns (uint8);
}

/**
 * @title PriceOracle
 * @dev A simple contract that needs to read a token's decimals to provide a normalized price.
 */
contract PriceOracle {
    /**
     * @notice Calculates a normalized price for a token.
     * @dev This function will revert if it cannot call `decimals()` on the token.
     * @param token The address of the token contract.
     * @param rawPrice The price of the token expressed as a raw integer (e.g., price in USD * 1e18).
     * @return The price normalized to the token's own decimal precision.
     */
    function getNormalizedPrice(
        IERC20 token,
        uint256 rawPrice
    ) public view returns (uint256) {
        uint8 tokenDecimals = token.decimals();
        // Adjust the raw price based on the token's decimals.
        // For example, if rawPrice is in 1e18 and tokenDecimals is 6, we adjust.
        if (tokenDecimals < 18) {
            return rawPrice / (10 ** (18 - tokenDecimals));
        } else {
            return rawPrice * (10 ** (tokenDecimals - 18));
        }
    }
}
