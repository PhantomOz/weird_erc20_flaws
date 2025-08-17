// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenReceiver {
    function tokenFallback(
        address from,
        uint256 amount,
        bytes calldata data
    ) external;
}

/**
 * @title CustomFallbackTokenFixed
 * @dev The corrected contract with secure authorization and transfer logic.
 */
contract CustomFallbackTokenFixed {
    address public owner;
    mapping(address => uint256) public balances;

    event OwnerSet(address indexed newOwner);

    modifier auth() {
        require(isAuthorized(msg.sender), "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice The corrected authorization check. It no longer trusts internal calls.
     */
    function isAuthorized(address src) internal view returns (bool) {
        // --- FIX 1 ---
        // The line `if (src == address(this))` has been removed.
        if (src == owner) {
            return true;
        }
        return false;
    }

    function setOwner(address newOwner) public auth {
        owner = newOwner;
        emit OwnerSet(newOwner);
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice A safer transfer function with a standard, non-customizable fallback.
     */
    function transfer(
        address _to,
        uint256 _amount,
        bytes calldata _data
    ) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        // --- FIX 2 ---
        // The fallback function name is fixed ("tokenFallback") and cannot be
        // manipulated by the caller.
        if (_to.code.length > 0) {
            try
                ITokenReceiver(_to).tokenFallback(msg.sender, _amount, _data)
            {} catch {} // Ignore failed fallbacks
        }
    }

    /**
     * @notice A helper function to demonstrate the auth fix for the test.
     * This simulates a re-entrant call attempting to change the owner.
     */
    function tryToCallSetOwnerInternally(address newOwner) public {
        // This internal call will now be correctly checked by `isAuthorized`,
        // which will check the original msg.sender, not the contract address.
        setOwner(newOwner);
    }
}
