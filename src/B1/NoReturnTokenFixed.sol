// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoReturnTokenFixed
 * @dev The corrected token contract that complies with the EIP-20 standard.
 */
contract NoReturnTokenFixed {
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
     * @dev CORRECTED: This function now returns a boolean value as required.
     */
    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance >= _value, "Insufficient balance");

        balances[msg.sender] = senderBalance - _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}
