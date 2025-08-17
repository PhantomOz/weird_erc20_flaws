// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoApprovalEventToken
 * @dev A token contract whose `approve` function fails to emit the required
 * `Approval` event, violating the ERC20 standard.
 */
contract NoApprovalEventToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    // The event is declared but never used in `approve`.
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Approves a spender for a certain amount.
     * @dev FLAWED: This function does not emit the `Approval` event.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        // MISSING: emit Approval(msg.sender, spender, value);
        return true;
    }
}
