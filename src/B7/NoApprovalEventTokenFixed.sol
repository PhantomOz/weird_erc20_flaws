// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title NoApprovalEventTokenFixed
 * @dev The corrected contract that emits the `Approval` event as required.
 */
contract NoApprovalEventTokenFixed {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Approves a spender for a certain amount.
     * @dev CORRECTED: Emits the `Approval` event to comply with the EIP-20 standard.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;

        // --- FIX ---
        emit Approval(msg.sender, spender, value);

        return true;
    }
}
