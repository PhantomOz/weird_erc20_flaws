// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BadDecimalsTokenFixed
 * @dev The corrected contract. It keeps the non-standard variable but adds
 * a compliant `decimals()` wrapper function for interoperability.
 */
contract BadDecimalsTokenFixed {
    // The non-standard variable name might be kept for internal reasons.
    uint8 public constant DECIMALS = 12;

    mapping(address => uint256) public balances;

    // --- FIX ---
    /**
     * @notice A compliant wrapper function for the non-standard DECIMALS variable.
     * @dev External contracts will call this function, which satisfies the ERC20 interface.
     */
    function decimals() external pure returns (uint8) {
        return DECIMALS;
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }
}
