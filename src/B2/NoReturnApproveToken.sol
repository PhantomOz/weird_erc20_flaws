// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoReturnApproveToken
 * @dev A token contract with an `approve` function that does not return a boolean,
 * violating the ERC20 standard and breaking interoperability.
 */
contract NoReturnApproveToken {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Approves a spender for a certain amount.
     * @dev FLAWED: This function does not return a boolean value as required
     * by the EIP-20 standard.
     */
    function approve(address _spender, uint256 _value) public {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }
}
