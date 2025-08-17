// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title InconsistentToken
 * @dev A token where `transferFrom` checks the spender's allowance
 * but incorrectly decrements the recipient's allowance, allowing
 * for an infinite spend exploit.
 */
contract InconsistentToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
    function approve(address spender, uint256 amount) public {
        allowance[msg.sender][spender] = amount;
    }

    /**
     * @dev VULNERABLE: Checks allowance of msg.sender, but decrements allowance of _to.
     */
    function transferFrom(address _from, address _to, uint256 _value) public {
        require(balances[_from] >= _value, "insufficient balance");
        require(
            allowance[_from][msg.sender] >= _value,
            "insufficient allowance"
        );

        balances[_from] -= _value;
        balances[_to] += _value;

        // --- FLAW ---
        // The allowance of the recipient is decreased, not the spender's.
        allowance[_from][_to] -= _value;
    }
}
