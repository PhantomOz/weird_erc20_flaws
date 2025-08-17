// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title RestrictiveApprovalTokenFixed
 * @dev The corrected version of the token contract, adhering to the
 * standard ERC20 `approve` function behavior.
 */
contract RestrictiveApprovalTokenFixed {
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
     * @dev CORRECTED: The balance check has been removed to comply with the
     * ERC20 standard and support common DeFi patterns.
     */
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }

    // A standard transfer function.
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}
