// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UnprotectedOwnerFixed
 * @dev This is the corrected version of the contract.
 * The `setOwner` function is now protected by an `onlyOwner` modifier.
 */
contract UnprotectedOwnerFixed {
    address public owner;

    event OwnerSet(address indexed newOwner);

    /**
     * @dev A modifier to ensure a function is only called by the contract owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Changes the owner of the contract.
     * @dev CORRECTED: This function is now protected with the `onlyOwner` modifier.
     * @param _newOwner The address of the new owner.
     */
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnerSet(_newOwner);
    }
}
