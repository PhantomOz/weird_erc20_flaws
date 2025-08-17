// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadSymbolTokenFixed
 * @dev The corrected contract. It keeps the non-standard variable but adds
 * a compliant `symbol()` wrapper function for interoperability.
 */
contract BadSymbolTokenFixed {
    // The non-standard variable name might be kept for internal reasons.
    string public constant SYMBOL = "FIX";

    mapping(address => uint256) public balances;

    // --- FIX ---
    /**
     * @notice A compliant wrapper function for the non-standard SYMBOL variable.
     * @dev External contracts and UIs will call this function, which satisfies the ERC20 interface.
     */
    function symbol() external pure returns (string memory) {
        return SYMBOL;
    }
}
