// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A22/MistypedConstructor.sol";
import "../src/A22/MistypedConstructorFixed.sol";

contract VulnerabilityTest is Test {
    // --- Actors ---
    address internal deployer = makeAddr("deployer");
    address internal attacker = makeAddr("attacker");
    address internal user = makeAddr("user");

    function test_A22_Exploit_ReinitializeAndBecomeOwner() public {
        // Arrange: Deployer deploys and initializes the contract.
        MistypedConstructor contract_ = new MistypedConstructor();
        vm.prank(deployer);
        contract_.init(deployer);
        assertEq(contract_.owner(), deployer);

        // Act: Attacker calls the public `init` function again.
        vm.prank(attacker);
        contract_.init(attacker);

        // Assert: Attacker has successfully taken ownership.
        assertEq(
            contract_.owner(),
            attacker,
            "Attacker should be the new owner"
        );
    }

    function test_A22_Mitigation_CannotReinitialize() public {
        // Arrange: Deployer deploys and initializes the fixed contract.
        MistypedConstructorFixed contract_ = new MistypedConstructorFixed();
        vm.prank(deployer);
        contract_.init(deployer);

        // Act & Assert: Attacker's attempt to re-initialize now reverts.
        vm.prank(attacker);
        vm.expectRevert("Contract is already initialized");
        contract_.init(attacker);

        // Final check: Owner remains the deployer.
        assertEq(contract_.owner(), deployer);
    }
}
