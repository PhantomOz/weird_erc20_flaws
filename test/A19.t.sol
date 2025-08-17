// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A19/RestrictiveApprovalToken.sol";
import "../src/A19/RestrictiveApprovalTokenFixed.sol";

contract RestrictiveApprovalTest is Test {
    RestrictiveApprovalToken internal flawedContract;
    RestrictiveApprovalTokenFixed internal fixedContract;

    address internal user = makeAddr("user");
    address internal dex = makeAddr("dex");
    address internal other = makeAddr("other");

    // --- FLAW DEMONSTRATION TESTS ---

    function test_Flaw_CannotSetInfiniteApproval() public {
        // Arrange: Deploy flawed contract and mint 1000 tokens to user.
        flawedContract = new RestrictiveApprovalToken();
        flawedContract.mint(user, 1000 ether);

        // Act & Assert: User tries to give the DEX an "infinite" approval
        // for future trades. The transaction reverts due to the flawed check.
        vm.prank(user);
        vm.expectRevert("Approval amount exceeds balance");
        flawedContract.approve(dex, type(uint256).max);

        // This token is now incompatible with many DeFi protocols.
    }

    function test_Flaw_CheckProvidesFalseSecurity() public {
        // Arrange: Deploy, mint, and user successfully approves an amount they own.
        flawedContract = new RestrictiveApprovalToken();
        flawedContract.mint(user, 1000 ether);

        vm.prank(user);
        flawedContract.approve(dex, 1000 ether);
        assertEq(flawedContract.allowance(user, dex), 1000 ether);

        // Act: Before the DEX can act, the user moves their funds.
        vm.prank(user);
        flawedContract.transfer(other, 1000 ether);
        assertEq(flawedContract.balances(user), 0);

        // Assert: The DEX allowance is still 1000, even though the user's balance
        // is zero. This proves the check in `approve` was pointless.
        assertEq(
            flawedContract.allowance(user, dex),
            1000 ether,
            "Allowance remains despite zero balance"
        );
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CanSetInfiniteApproval() public {
        // Arrange: Deploy the fixed contract and mint tokens to user.
        fixedContract = new RestrictiveApprovalTokenFixed();
        fixedContract.mint(user, 1000 ether);

        // Act: The user gives an infinite approval to the DEX.
        vm.prank(user);
        fixedContract.approve(dex, type(uint256).max);

        // Assert: The approval is successful, making the token compatible with standard DeFi protocols.
        assertEq(fixedContract.allowance(user, dex), type(uint256).max);
    }
}
