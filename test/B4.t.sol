// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B4/BadDecimalsToken.sol";
import "../src/B4/BadDecimalsTokenFixed.sol";
import "../src/B4/PriceOracle.sol";

contract BadDecimalsTest is Test {
    // --- FLAW DEMONSTRATION TEST ---

    function test_Flaw_CallingContractCannotReadDecimals() public {
        // Arrange: Deploy the flawed token and the price oracle.
        BadDecimalsToken flawedToken = new BadDecimalsToken();
        PriceOracle oracle = new PriceOracle();

        // Act & Assert: The oracle's call reverts because it cannot find the
        // `decimals()` function on the flawed token contract. The function selector
        // for `decimals()` does not match the public variable `DECIMALS`.
        vm.expectRevert();
        oracle.getNormalizedPrice(IERC20(address(flawedToken)), 2000 * 1e18);
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CallingContractCanReadDecimals() public {
        // Arrange: Deploy the FIXED token and the price oracle.
        BadDecimalsTokenFixed fixedToken = new BadDecimalsTokenFixed();
        PriceOracle oracle = new PriceOracle();

        // The token has 12 decimals. The raw price is 2000 * 1e18.
        // The normalized price should be 2000 * 1e18 / 10^(18-12) = 2000 * 1e12.
        uint256 rawPrice = 2000 * 1e18;
        uint256 expectedNormalizedPrice = 2000 * 1e12;

        // Act: The call to the oracle now succeeds.
        uint256 normalizedPrice = oracle.getNormalizedPrice(
            IERC20(address(fixedToken)),
            rawPrice
        );

        // Assert: The oracle was able to fetch the decimals and return the correct price.
        assertEq(
            normalizedPrice,
            expectedNormalizedPrice,
            "Normalized price is incorrect"
        );
    }
}
