// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B6/BadSymbolToken.sol";
import "../src/B6/BadSymbolTokenFixed.sol";
import "../src/B6/TokenRegistry.sol";

contract BadSymbolTest is Test {
    // --- FLAW DEMONSTRATION TEST ---

    function test_Flaw_CallingContractCannotReadSymbol() public {
        // Arrange: Deploy the flawed token and the token registry.
        BadSymbolToken flawedToken = new BadSymbolToken();
        TokenRegistry registry = new TokenRegistry();

        // Act & Assert: The registry's call reverts because it cannot find the
        // `symbol()` function on the flawed token contract. The function selector
        // for `symbol()` does not match the public variable `SYMBOL`.
        vm.expectRevert();
        registry.registerToken(IERC20(address(flawedToken)));
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CallingContractCanReadSymbol() public {
        // Arrange: Deploy the FIXED token and the token registry.
        BadSymbolTokenFixed fixedToken = new BadSymbolTokenFixed();
        TokenRegistry registry = new TokenRegistry();

        string memory expectedSymbol = "FIX";

        // Act: The call to the registry now succeeds.
        registry.registerToken(IERC20(address(fixedToken)));

        // Assert: The registry was able to fetch the symbol and store it correctly.
        assertEq(
            registry.registeredTokenSymbols(address(fixedToken)),
            expectedSymbol
        );
    }
}
