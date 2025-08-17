// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A20/ReApproveToken.sol";
import "../src/A20/ReApproveTokenFixed.sol";

contract VulnerabilityTest is Test {
    // --- Actors ---
    address internal alice = makeAddr("alice");
    address internal spender = makeAddr("spender");
    address internal recipient = makeAddr("recipient");

    function test_A20_Exploit_ReApproveRaceCondition() public {
        ReApproveToken token = new ReApproveToken();
        token.mint(alice, 1000 ether);

        // 1. Alice approves spender for 100 tokens.
        vm.prank(alice);
        token.approve(spender, 100 ether);

        // 2. SIMULATE RACE: Spender front-runs Alice's new approval.
        // Spender's tx (spends 100) -> Alice's tx (sets approval to 50)
        vm.prank(spender);
        token.transferFrom(alice, spender, 100 ether);

        vm.prank(alice);
        token.approve(spender, 50 ether);

        // 3. Spender spends the new 50 token allowance.
        vm.prank(spender);
        token.transferFrom(alice, spender, 50 ether);

        // Assert: Spender has spent 150 tokens in total.
        assertEq(
            token.balances(spender),
            150 ether,
            "Spender should have 150 tokens"
        );
        assertEq(
            token.balances(alice),
            850 ether,
            "Alice should have 850 tokens left"
        );
    }

    function test_A20_Mitigation_DecreaseApprovalPreventsRace() public {
        ReApproveTokenFixed token = new ReApproveTokenFixed();
        token.mint(alice, 1000 ether);

        // 1. Alice approves spender for 100.
        vm.prank(alice);
        token.approve(spender, 100 ether);

        // 2. Alice safely decreases the approval to 40.
        vm.prank(alice);
        token.decreaseApproval(spender, 60 ether); // 100 - 60 = 40

        assertEq(
            token.allowance(alice, spender),
            40 ether,
            "Allowance should be 40"
        );

        // Assert: Spender cannot spend more than the new allowance.
        vm.prank(spender);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(alice, spender, 50 ether);
    }
}
