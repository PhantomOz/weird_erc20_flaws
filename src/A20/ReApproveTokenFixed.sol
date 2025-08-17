// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ReApproveTokenFixed
 * @dev A token contract that implements `increaseApproval` and `decreaseApproval`
 * to mitigate the ERC20 re-approve race condition.
 */
contract ReApproveTokenFixed {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }
    function transferFrom(address from, address to, uint256 amount) public {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(balances[from] >= amount, "insufficient balance");
        require(currentAllowance >= amount, "insufficient allowance");
        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] = currentAllowance - amount;
    }

    // --- MITIGATION ---
    function increaseApproval(address spender, uint256 addedValue) public {
        uint256 currentAllowance = allowance[msg.sender][spender];
        allowance[msg.sender][spender] = currentAllowance + addedValue;
    }

    function decreaseApproval(address spender, uint256 subtractedValue) public {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "decreased allowance below zero"
        );
        allowance[msg.sender][spender] = currentAllowance - subtractedValue;
    }
}
