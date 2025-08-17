// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadNameTokenFixed
 * @dev The corrected contract. It keeps the non-standard variable but adds
 * a compliant `name()` wrapper function for interoperability.
 */
contract BadNameTokenFixed {
    // The non-standard variable name might be kept for internal reasons.
    string public constant NAME = "My Fixed Token";

    mapping(address => uint256) public balances;

    // --- FIX ---
    /**
     * @notice A compliant wrapper function for the non-standard NAME variable.
     * @dev External contracts and UIs will call this function, which satisfies the ERC20 interface.
     */
    function name() external pure returns (string memory) {
        return NAME;
    }
}
