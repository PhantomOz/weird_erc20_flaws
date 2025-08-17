// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B2/NoReturnApproveToken.sol";
import "../src/B2/NoReturnApproveTokenFixed.sol";
import "../src/B2/ApprovalManager.sol";

contract NoReturnApproveTest is Test {
    // --- FLAW DEMONSTRATION TEST ---

    function test_Flaw_CallingContractRevertsOnApprove() public {
        // Arrange: Deploy the flawed token and the approval manager.
        NoReturnApproveToken flawedToken = new NoReturnApproveToken();
        ApprovalManager manager = new ApprovalManager();

        address spender = makeAddr("spender");

        // Act & Assert: The call to `setApproval` reverts because the manager
        // expects a boolean return from `approve`, but the flawed token provides none.
        vm.expectRevert();
        manager.setApproval(address(flawedToken), spender, 100 ether);
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CallingContractSucceedsOnApprove() public {
        // Arrange: Deploy the FIXED token and the approval manager.
        NoReturnApproveTokenFixed fixedToken = new NoReturnApproveTokenFixed();
        ApprovalManager manager = new ApprovalManager();

        address owner = address(manager); // The manager is the token holder in this case
        address spender = makeAddr("spender");
        uint256 approvalAmount = 100 ether;

        // Act: The call to `setApproval` now succeeds.
        manager.setApproval(address(fixedToken), spender, approvalAmount);

        // Assert: The approval was successful and the allowance was set correctly in the token contract.
        assertEq(fixedToken.allowance(owner, spender), approvalAmount);
    }
}
