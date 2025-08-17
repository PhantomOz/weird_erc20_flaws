// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that correctly expects a boolean return from approve.
interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
}

/**
 * @title ApprovalManager
 * @dev A simple contract that helps a user set an approval on a token. It expects to
 * interact with a compliant ERC20 token.
 */
contract ApprovalManager {
    event ApprovalSet(
        address indexed user,
        address indexed token,
        address indexed spender,
        uint256 amount
    );

    /**
     * @notice A user calls this function to have this contract set an approval on their behalf.
     * @dev This function will revert if the `token` contract's approve
     * function does not return a boolean.
     */
    function setApproval(
        address token,
        address spender,
        uint256 amount
    ) public {
        // This contract needs to call the token on behalf of the user.
        // In a real scenario, this might be a meta-transaction. For this test,
        // we'll simulate it by having the user pass in the token and this contract
        // will attempt the approval (this is a bit contrived, but demonstrates the call revert).
        // A more realistic example is a Staking contract approving its rewards distributor.

        // Let's assume this contract holds the tokens and is approving a spender.
        bool success = IERC20(token).approve(spender, amount);
        require(success, "Approval failed");
        emit ApprovalSet(msg.sender, token, spender, amount);
    }
}
