// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoReturnTransferFromToken
 * @dev A token contract with a `transferFrom` function that does not return a boolean,
 * violating the ERC20 standard and breaking interoperability.
 */
contract NoReturnTransferFromToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    function approve(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    /**
     * @notice Transfers tokens from one address to another on behalf of the owner.
     * @dev FLAWED: This function does not return a boolean value as required by EIP-20.
     */
    function transferFrom(address _from, address _to, uint256 _value) public {
        uint256 currentAllowance = allowance[_from][msg.sender];
        require(balances[_from] >= _value, "Insufficient balance");
        require(currentAllowance >= _value, "Insufficient allowance");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowance[_from][msg.sender] = currentAllowance - _value;
        emit Transfer(_from, _to, _value);
    }
}
