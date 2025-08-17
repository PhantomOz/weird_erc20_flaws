// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B5/BadNameToken.sol";
import "../src/B5/BadNameTokenFixed.sol";
import "../src/B5/TokenRegistry.sol";

contract BadNameTest is Test {
    // --- FLAW DEMONSTRATION TEST ---

    function test_Flaw_CallingContractCannotReadName() public {
        // Arrange: Deploy the flawed token and the token registry.
        BadNameToken flawedToken = new BadNameToken();
        TokenRegistry registry = new TokenRegistry();

        // Act & Assert: The registry's call reverts because it cannot find the
        // `name()` function on the flawed token contract. The function selector
        // for `name()` does not match the public variable `NAME`.
        vm.expectRevert();
        registry.registerToken(IERC20(address(flawedToken)));
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CallingContractCanReadName() public {
        // Arrange: Deploy the FIXED token and the token registry.
        BadNameTokenFixed fixedToken = new BadNameTokenFixed();
        TokenRegistry registry = new TokenRegistry();

        string memory expectedName = "My Fixed Token";

        // Act: The call to the registry now succeeds.
        registry.registerToken(IERC20(address(fixedToken)));

        // Assert: The registry was able to fetch the name and store it correctly.
        assertEq(
            registry.registeredTokenNames(address(fixedToken)),
            expectedName
        );
    }
}
