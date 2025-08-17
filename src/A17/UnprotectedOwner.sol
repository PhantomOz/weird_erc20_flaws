// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UnprotectedOwner
 * @dev This contract contains a `setOwner` function that lacks access control.
 * Anyone can call it and take ownership of the contract.
 */
contract UnprotectedOwner {
    address public owner;

    event OwnerSet(address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Changes the owner of the contract.
     * @dev VULNERABLE: This function has no access control. Any address can call it.
     * @param _newOwner The address of the new owner.
     */
    function setOwner(address _newOwner) public {
        owner = _newOwner;
        emit OwnerSet(_newOwner);
    }
}
