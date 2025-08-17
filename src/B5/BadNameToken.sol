// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadNameToken
 * @dev A token contract that uses a non-standard, uppercase name for its
 * name variable, making it incompatible with standard ERC20 interfaces.
 */
contract BadNameToken {
    // FLAW: The variable name `NAME` is non-standard.
    // Standard interfaces look for `name` (lowercase).
    string public constant NAME = "My Flawed Token";

    // Basic ERC20 state for context
    mapping(address => uint256) public balances;
}
