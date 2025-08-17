// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MistypedConstructorFixed
 * @dev The corrected contract. It uses a boolean flag and a modifier
 * to ensure the `init` function can only be called once.
 */
contract MistypedConstructorFixed {
    address public owner;
    bool private isInitialized;

    event OwnerSet(address indexed newOwner);

    modifier notInitialized() {
        require(!isInitialized, "Contract is already initialized");
        _;
    }

    /**
     * @notice A secure initializer function.
     * @dev CORRECTED: It is now protected by the `notInitialized` modifier.
     */
    function init(address _newOwner) public notInitialized {
        isInitialized = true;
        owner = _newOwner;
        emit OwnerSet(_newOwner);
    }
}
