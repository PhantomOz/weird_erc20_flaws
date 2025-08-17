// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that correctly expects a boolean return from transferFrom.
interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

/**
 * @title PaymentProcessor
 * @dev A simple contract that processes a payment by pulling funds from a user.
 * It expects to interact with a compliant ERC20 token.
 */
contract PaymentProcessor {
    event PaymentProcessed(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /**
     * @notice Pulls funds from `from` to `to` after `from` has approved this contract.
     * @dev This function will revert if the `token`'s `transferFrom` function
     * does not return a boolean.
     */
    function processPayment(
        IERC20 token,
        address from,
        address to,
        uint256 amount
    ) public {
        bool success = token.transferFrom(from, to, amount);
        require(success, "Payment transfer failed");
        emit PaymentProcessed(from, to, amount);
    }
}
