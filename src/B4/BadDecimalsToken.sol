// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadDecimalsToken
 * @dev A token contract that uses a non-standard, uppercase name for its
 * decimals variable, making it incompatible with standard ERC20 interfaces.
 */
contract BadDecimalsToken {
    // FLAW: The variable name `DECIMALS` is non-standard.
    // Standard interfaces look for `decimals` (lowercase).
    uint8 public constant DECIMALS = 12;

    mapping(address => uint256) public balances;

    function mint(address to, uint256 amount) public {
        // We mint the raw amount, assuming it's already adjusted for decimals.
        balances[to] += amount;
    }
}
