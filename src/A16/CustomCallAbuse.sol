// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CustomCallAbuse
 * @dev This contract contains a generic `execute` function that allows anyone
 * to make an arbitrary call from this contract's address. This turns the
 * contract into an "open proxy" that can be abused to steal funds approved
 * to it.
 */
contract CustomCallAbuse {
    event Executed(address indexed target, bytes data, bool success);

    /**
     * @notice Executes an arbitrary call to a target contract.
     * @param target The address of the contract to call.
     * @param data The calldata to send in the call.
     * @dev VULNERABILITY: Anyone can call this and make the contract perform
     * any action, such as calling `transferFrom` on a token it has an
     * allowance for.
     */
    function execute(address target, bytes calldata data) external payable {
        (bool success, ) = target.call{value: msg.value}(data);
        require(success, "External call failed");
        emit Executed(target, data, success);
    }
}
