// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoReturnApproveTokenFixed
 * @dev The corrected token contract that complies with the EIP-20 `approve` standard.
 */
contract NoReturnApproveTokenFixed {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Approves a spender for a certain amount.
     * @dev CORRECTED: This function now returns a boolean value as required.
     */
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}
