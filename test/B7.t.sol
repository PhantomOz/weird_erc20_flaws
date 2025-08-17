// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B7/NoApprovalEventToken.sol";
import "../src/B7/NoApprovalEventTokenFixed.sol";

contract NoApprovalEventTest is Test {
    address internal user = makeAddr("user");
    address internal spender = makeAddr("spender");
    uint256 internal approvalAmount = 100 ether;

    // --- FLAW DEMONSTRATION TEST ---

    /**
     * @notice This test is expected to FAIL against the flawed contract.
     * The failure proves that the `Approval` event was not emitted.
     */
    function test_Flaw_ApproveDoesNotEmitEvent() public {
        NoApprovalEventToken flawedToken = new NoApprovalEventToken();

        // We tell Foundry to expect an `Approval` event with specific indexed fields (owner, spender)
        // and data fields (value). The `check` flags correspond to:
        // topic1 (owner), topic2 (spender), topic3 (none), data (value)
        vm.expectEmit(true, true, false, true);
        emit NoApprovalEventToken.Approval(user, spender, approvalAmount);

        // We call the flawed function. Foundry will see that the expected
        // event was not emitted and will fail this test.
        vm.prank(user);
        flawedToken.approve(spender, approvalAmount);
    }

    // --- MITIGATION TEST ---

    /**
     * @notice This test will PASS against the fixed contract.
     * It uses the same logic as the test above, but now the contract
     * correctly emits the event, satisfying Foundry's expectation.
     */
    function test_Mitigation_ApproveEmitsEvent() public {
        NoApprovalEventTokenFixed fixedToken = new NoApprovalEventTokenFixed();

        // Set up the same expectation for the event.
        vm.expectEmit(true, true, false, true);
        emit NoApprovalEventTokenFixed.Approval(user, spender, approvalAmount);

        // Call the fixed function. The test now passes because the event is emitted.
        vm.prank(user);
        fixedToken.approve(spender, approvalAmount);

        // Final check to ensure state was also updated correctly.
        assertEq(fixedToken.allowance(user, spender), approvalAmount);
    }
}
