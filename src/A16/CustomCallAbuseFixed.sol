// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Example of a safe, specific interface the contract might interact with.
interface ISafePartner {
    function depositFor(address user, uint256 amount) external;
}

// Example of an approved token interface (ERC20).
interface IApprovedToken {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title CustomCallAbuseFixed
 * @dev This contract removes the arbitrary `execute` function.
 * Instead, it exposes only specific, hardcoded functions for its
 * intended purpose, preventing abuse of approvals.
 */
contract CustomCallAbuseFixed {
    ISafePartner public immutable partner;
    IApprovedToken public immutable token;

    constructor(address _partner, address _token) {
        partner = ISafePartner(_partner);
        token = IApprovedToken(_token);
    }

    /**
     * @notice A safe function that interacts with an approved token and a partner contract.
     * @dev The targets (`token`, `partner`) and the functions called (`transferFrom`, `depositFor`)
     * are hardcoded and cannot be controlled by the caller. This is safe.
     */
    function deposit(uint256 amount) external {
        // The contract pulls tokens from the user who approved it.
        token.transferFrom(msg.sender, address(this), amount);

        // The contract then deposits those tokens into the partner contract.
        // The destination is fixed and cannot be changed by an attacker.
        partner.depositFor(msg.sender, amount);
    }
}
