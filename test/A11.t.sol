// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A11/PauseTransferAnyone.sol";
import "../src/A11/PauseTransferAnyoneFixed.sol";

contract PauseTransferAnyoneTest is Test {
    PauseTransferAnyone internal vulnerableToken;
    PauseTransferAnyoneFixed internal fixedToken;

    address internal admin = makeAddr("admin");
    address internal attacker = makeAddr("attacker");
    address internal user = makeAddr("user");

    function setUp() public {
        vm.prank(user);
        vulnerableToken = new PauseTransferAnyone(admin);
        // vulnerableToken.transfer(user, 100 * 1e18);
    }

    // --- VULNERABILITY TESTS ---

    function test_Exploit_AttackerCanEnableAndDisableTransfers() public {
        // 1. Check initial state: transfers are disabled.
        assertFalse(
            vulnerableToken.tokenTransfer(),
            "Transfers should be disabled initially"
        );

        // 2. Attacker enables transfers. This should not be possible.
        vm.prank(attacker);
        vulnerableToken.enableTokenTransfer();
        assertTrue(
            vulnerableToken.tokenTransfer(),
            "Attacker should have enabled transfers"
        );

        // 3. Attacker disables transfers again, demonstrating full control.
        vm.prank(attacker);
        vulnerableToken.disableTokenTransfer();
        assertFalse(
            vulnerableToken.tokenTransfer(),
            "Attacker should have disabled transfers"
        );
    }

    function test_Exploit_AdminIsLockedOut() public {
        // The intended admin tries to enable transfers.
        vm.prank(admin);

        // The call reverts because of the flawed '!=' logic.
        vm.expectRevert("Incorrect logic: allows anyone but admin");
        vulnerableToken.enableTokenTransfer();
    }

    function test_Exploit_UserCannotTransferWhenPausedByAttacker() public {
        // Initially, transfers are off. A regular user cannot transfer.
        vm.prank(user);
        vm.expectRevert("Transfers are paused");
        vulnerableToken.transfer(attacker, 10 * 1e18);

        // Attacker enables transfers
        vm.prank(attacker);
        vulnerableToken.enableTokenTransfer();

        // Now the user can transfer
        vm.prank(user);
        vulnerableToken.transfer(attacker, 10 * 1e18);
        assertEq(vulnerableToken.balanceOf(user), 990 * 1e18);

        // Attacker disables transfers again, trapping the user's funds.
        vm.prank(attacker);
        vulnerableToken.disableTokenTransfer();

        // User's transfer fails again.
        vm.prank(user);
        vm.expectRevert("Transfers are paused");
        vulnerableToken.transfer(attacker, 10 * 1e18);
    }

    // --- MITIGATION TESTS ---

    function test_Mitigation_AttackerCannotControlTransfers() public {
        // Deploy the fixed contract
        fixedToken = new PauseTransferAnyoneFixed(admin);

        // Attacker tries to enable transfers
        vm.prank(attacker);

        // The call now correctly reverts
        vm.expectRevert("Caller is not the admin");
        fixedToken.enableTokenTransfer();
    }

    function test_Mitigation_AdminCanControlTransfers() public {
        // Deploy the fixed contract
        fixedToken = new PauseTransferAnyoneFixed(admin);

        // 1. Check initial state: transfers are disabled.
        assertFalse(
            fixedToken.tokenTransfer(),
            "Transfers should be disabled initially"
        );

        // 2. Admin enables transfers.
        vm.prank(admin);
        fixedToken.enableTokenTransfer();
        assertTrue(
            fixedToken.tokenTransfer(),
            "Admin should have enabled transfers"
        );

        // 3. Admin disables transfers again.
        vm.prank(admin);
        fixedToken.disableTokenTransfer();
        assertFalse(
            fixedToken.tokenTransfer(),
            "Admin should have disabled transfers"
        );
    }
}
