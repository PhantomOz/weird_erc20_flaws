// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that correctly expects a boolean return.
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

/**
 * @title TokenAirdropper
 * @dev A simple contract that attempts to airdrop tokens. It expects to
 * interact with a compliant ERC20 token.
 */
contract TokenAirdropper {
    /**
     * @notice Distributes a fixed amount of a token to multiple recipients.
     * @dev This function will revert if the `token` contract's transfer
     * function does not return a boolean.
     */
    function distribute(
        IERC20 token,
        address[] calldata recipients,
        uint256 amount
    ) public {
        for (uint i = 0; i < recipients.length; i++) {
            bool success = token.transfer(recipients[i], amount);
            require(success, "Airdrop transfer failed");
        }
    }
}
