// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A21/InconsistentToken.sol";
import "../src/A21/InconsistentTokenFixed.sol";

contract VulnerabilityTest is Test {
    // --- Actors ---
    address internal alice = makeAddr("alice");
    address internal spender = makeAddr("spender");
    address internal recipient = makeAddr("recipient");

    function test_A21_Exploit_InconsistentCheckAllowsInfiniteSpend() public {
        InconsistentToken token = new InconsistentToken();
        token.mint(alice, 1000 ether);

        // 1. Alice approves `spender` for 100, and `recipient` for 100 (to avoid revert).
        vm.prank(alice);
        token.approve(spender, 100 ether);
        vm.prank(alice);
        token.approve(recipient, 100 ether);

        // 2. Spender transfers 100 from Alice to Recipient.
        // The check on `spender`'s allowance passes.
        // The effect is on `recipient`'s allowance.
        vm.prank(spender);
        token.transferFrom(alice, recipient, 100 ether);

        // 3. Assert: Recipient got the tokens, but spender's allowance is UNCHANGED.
        assertEq(token.balances(recipient), 100 ether);
        assertEq(
            token.allowance(alice, recipient),
            0,
            "Recipient's allowance should be 0"
        );
        assertEq(
            token.allowance(alice, spender),
            100 ether,
            "Spender's allowance should still be 100"
        );

        // 4. Spender can spend again (but tx would revert as recipient allowance is now 0).
        // This proves the spender's allowance was not consumed.
    }

    function test_A21_Mitigation_AllowanceIsProperlyConsumed() public {
        InconsistentTokenFixed token = new InconsistentTokenFixed();
        token.mint(alice, 1000 ether);

        // 1. Alice approves spender for 100.
        vm.prank(alice);
        token.approve(spender, 100 ether);

        // 2. Spender transfers 100 tokens from Alice.
        vm.prank(spender);
        token.transferFrom(alice, recipient, 100 ether);

        // 3. Assert: Spender's allowance is now correctly 0.
        assertEq(
            token.allowance(alice, spender),
            0,
            "Spender's allowance should now be 0"
        );

        // 4. A second attempt to spend fails.
        vm.prank(spender);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(alice, recipient, 1 ether);
    }
}
