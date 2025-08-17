// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A17/UnprotectedOwner.sol";
import "../src/A17/UnprotectedOwnerFixed.sol";

contract UnprotectedOwnerTest is Test {
    UnprotectedOwner internal vulnerableContract;
    UnprotectedOwnerFixed internal fixedContract;

    address internal deployer = makeAddr("deployer");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        vulnerableContract = new UnprotectedOwner();
    }

    // --- VULNERABILITY TEST ---

    function test_Exploit_AttackerCanBecomeOwner() public {
        // Arrange: Check initial state.
        assertEq(
            vulnerableContract.owner(),
            deployer,
            "Initial owner should be the deployer."
        );
        assertNotEq(
            vulnerableContract.owner(),
            attacker,
            "Attacker should not be the owner initially."
        );

        // Act: Attacker calls the unprotected setOwner function.
        vm.prank(attacker);
        vulnerableContract.setOwner(attacker);

        // Assert: The owner of the contract has been changed to the attacker.
        assertEq(
            vulnerableContract.owner(),
            attacker,
            "Attacker should now be the new owner."
        );
    }

    // --- MITIGATION TESTS ---

    function test_Mitigation_AttackerCannotBecomeOwner() public {
        // Arrange: Deploy the fixed contract.
        vm.prank(deployer);
        fixedContract = new UnprotectedOwnerFixed();

        // Act & Assert: Attacker's attempt to call setOwner now reverts.
        vm.prank(attacker);
        vm.expectRevert("Caller is not the owner");
        fixedContract.setOwner(attacker);

        // Final check: The owner remains the deployer.
        assertEq(
            fixedContract.owner(),
            deployer,
            "Owner should not have changed."
        );
    }

    function test_Mitigation_OwnerCanChangeOwner() public {
        // Arrange: Deploy the fixed contract.
        vm.prank(deployer);
        fixedContract = new UnprotectedOwnerFixed();

        // Act: The legitimate owner successfully changes the owner.
        address newOwner = makeAddr("newOwner");
        vm.prank(deployer);
        fixedContract.setOwner(newOwner);

        // Assert: The owner has been updated.
        assertEq(
            fixedContract.owner(),
            newOwner,
            "Owner should have been updated."
        );
    }
}
