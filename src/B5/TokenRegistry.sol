// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that includes the `name` function.
interface IERC20 {
    function name() external view returns (string memory);
}

/**
 * @title TokenRegistry
 * @dev A simple contract that registers other tokens by reading their names.
 */
contract TokenRegistry {
    mapping(address => string) public registeredTokenNames;

    /**
     * @notice Registers a token by fetching and storing its name.
     * @dev This function will revert if it cannot call `name()` on the token.
     */
    function registerToken(IERC20 token) public {
        string memory tokenName = token.name();
        registeredTokenNames[address(token)] = tokenName;
    }
}
