// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RestrictiveApprovalToken
 * @dev A token contract with a non-standard `approve` function that
 * incorrectly checks the user's balance. This breaks compatibility with
 * common DeFi patterns like "infinite approval".
 */
contract RestrictiveApprovalToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice Approves a spender for a certain amount.
     * @dev FLAWED: This function includes a non-standard require statement
     * that checks the sender's balance, preventing infinite approvals.
     */
    function approve(address spender, uint256 amount) public {
        // --- PROBLEMATIC CHECK ---
        require(
            balances[msg.sender] >= amount,
            "Approval amount exceeds balance"
        );
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    // A standard transfer function to help demonstrate the flaw.
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
