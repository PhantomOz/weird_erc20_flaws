// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadSymbolToken
 * @dev A token contract that uses a non-standard, uppercase name for its
 * symbol variable, making it incompatible with standard ERC20 interfaces.
 */
contract BadSymbolToken {
    // FLAW: The variable name `SYMBOL` is non-standard.
    // Standard interfaces look for `symbol` (lowercase).
    string public constant SYMBOL = "FLAW";

    // Basic ERC20 state for context
    mapping(address => uint256) public balances;
}
