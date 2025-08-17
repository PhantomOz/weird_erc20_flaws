// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ReApproveToken
 * @dev A standard token contract whose `approve` function is susceptible
 * to the classic ERC20 re-approve race condition.
 */
contract ReApproveToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
    function transferFrom(address from, address to, uint256 amount) public {
        require(balances[from] >= amount, "insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "insufficient allowance"
        );
        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] -= amount;
    }

    /**
     * @dev VULNERABLE: Setting an absolute approval value opens a race condition.
     */
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }
}
