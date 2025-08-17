// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MistypedConstructor
 * @dev This contract demonstrates the modern equivalent of a mistyped constructor
 * vulnerability. The `init` function, which sets the owner, is public and
 * can be called by anyone at any time to hijack ownership.
 */
contract MistypedConstructor {
    address public owner;

    event OwnerSet(address indexed newOwner);

    /**
     * @notice A vulnerable initializer function meant to act as a constructor.
     * @dev It lacks any protection to ensure it's only called once.
     */
    function init(address _newOwner) public {
        owner = _newOwner;
        emit OwnerSet(_newOwner);
    }
}
