// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoReturnToken
 * @dev A token contract with a `transfer` function that does not return a boolean,
 * violating the ERC20 standard and breaking interoperability.
 */
contract NoReturnToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    /**
     * @notice Transfers tokens to a specified address.
     * @dev FLAWED: This function does not return a boolean value as required
     * by the EIP-20 standard.
     */
    function transfer(address _to, uint256 _value) public {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value, "Insufficient balance");

        balances[msg.sender] = senderBalance - _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
    }
}
