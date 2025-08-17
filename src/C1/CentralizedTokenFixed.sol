// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CentralizedTokenFixed
 * @dev The corrected contract. The fix is the complete removal of the
 * dangerously centralized `zero_fee_transaction` function.
 */
contract CentralizedTokenFixed {
    mapping(address => uint256) public balances;
    address public centralAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);

    // The `onlyCentralAccount` modifier might be kept for other, safer admin functions
    // (e.g., pausing the contract), but not for moving user funds.
    modifier onlyCentralAccount() {
        require(
            msg.sender == centralAccount,
            "Caller is not the central account"
        );
        _;
    }

    constructor(address _centralAccount) {
        centralAccount = _centralAccount;
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    //
    // --- FIX ---
    // The `zero_fee_transaction` function has been completely removed.
    // Privileged accounts should never have the ability to arbitrarily move user funds.
    // The standard `approve` and `transferFrom` mechanism (not implemented here for
    // simplicity) is the correct pattern for all third-party transfers as it
    // requires user consent.
    //
}
