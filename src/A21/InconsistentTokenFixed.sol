// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InconsistentTokenFixed
 * @dev The corrected contract where `transferFrom` properly decrements
 * the spender's (msg.sender) allowance.
 */
contract InconsistentTokenFixed {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }

    /**
     * @dev CORRECTED: Now decrements the allowance of msg.sender.
     */
    function transferFrom(address _from, address _to, uint256 _value) public {
        uint256 currentAllowance = allowance[_from][msg.sender];
        require(balances[_from] >= _value, "insufficient balance");
        require(currentAllowance >= _value, "insufficient allowance");

        balances[_from] -= _value;
        balances[_to] += _value;

        // --- FIX ---
        allowance[_from][msg.sender] = currentAllowance - _value;
    }
}
