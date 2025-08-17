// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/B3/NoReturnTransferFromToken.sol";
import "../src/B3/NoReturnTransferFromTokenFixed.sol";
import "../src/B3/PaymentProcessor.sol";

contract NoReturnTransferFromTest is Test {
    address internal user = makeAddr("user");
    address internal recipient = makeAddr("recipient");

    // --- FLAW DEMONSTRATION TEST ---

    function test_Flaw_CallingContractRevertsOnTransferFrom() public {
        // Arrange: Deploy the flawed token and the payment processor.
        NoReturnTransferFromToken flawedToken = new NoReturnTransferFromToken();
        PaymentProcessor processor = new PaymentProcessor();

        // User gets tokens and approves the processor to spend them.
        flawedToken.mint(user, 1000 ether);
        vm.prank(user);
        flawedToken.approve(address(processor), 500 ether);

        // Act & Assert: The call to `processPayment` reverts because the processor
        // expects a boolean return from `transferFrom`, but the flawed token provides none.
        vm.prank(address(this)); // Anyone can initiate the payment processing
        vm.expectRevert();
        processor.processPayment(
            IERC20(address(flawedToken)),
            user,
            recipient,
            100 ether
        );
    }

    // --- MITIGATION TEST ---

    function test_Mitigation_CallingContractSucceedsOnTransferFrom() public {
        // Arrange: Deploy the FIXED token and the payment processor.
        NoReturnTransferFromTokenFixed fixedToken = new NoReturnTransferFromTokenFixed();
        PaymentProcessor processor = new PaymentProcessor();

        // User gets tokens and approves the processor.
        uint256 paymentAmount = 100 ether;
        fixedToken.mint(user, 1000 ether);
        vm.prank(user);
        fixedToken.approve(address(processor), 500 ether);

        // Act: The call to `processPayment` now succeeds.
        processor.processPayment(
            IERC20(address(fixedToken)),
            user,
            recipient,
            paymentAmount
        );

        // Assert: The payment was successful and balances were updated correctly.
        assertEq(fixedToken.balances(user), 900 ether);
        assertEq(fixedToken.balances(recipient), 100 ether);
        assertEq(fixedToken.allowance(user, address(processor)), 400 ether);
    }
}
