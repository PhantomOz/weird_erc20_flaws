// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CustomFallbackToken
 * @dev A token with a flawed authorization mechanism that can be bypassed
 * via a re-entrant call from its own vulnerable transfer function.
 */
contract CustomFallbackToken {
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
     * @notice A flawed authorization check that blindly trusts internal calls.
     */
    function isAuthorized(address src) internal view returns (bool) {
        // --- VULNERABILITY 1 ---
        // The contract automatically authorizes any call originating from itself.
        if (src == address(this)) {
            return true;
        }
        if (src == owner) {
            return true;
        }
        return false;
    }

    /**
     * @notice A privileged function that an attacker will target.
     */
    function setOwner(address newOwner) public auth {
        owner = newOwner;
        emit OwnerSet(newOwner);
    }

    /**
     * @notice Mints tokens for test setup.
     */
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice A transfer function with a custom fallback mechanism.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data,
        string calldata _custom_fallback
    ) public {
        require(balances[_from] >= _amount, "Insufficient balance");
        balances[_from] -= _amount;
        balances[_to] += _amount;

        // --- VULNERABILITY 2 ---
        // If _to is this contract, it makes a call to itself with a user-provided
        // function signature, which gets authorized by the flawed `isAuthorized`.
        if (_to.code.length > 0) {
            (bool success, ) = _to.call(
                abi.encodePacked(
                    bytes4(keccak256(bytes(_custom_fallback))),
                    _data
                )
            );
            require(success, "Fallback call failed");
        }
    }
}
