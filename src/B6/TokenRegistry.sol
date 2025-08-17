// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// A standard ERC20 interface that includes the `symbol` function.
interface IERC20 {
    function symbol() external view returns (string memory);
}

/**
 * @title TokenRegistry
 * @dev A simple contract that registers other tokens by reading their symbols.
 */
contract TokenRegistry {
    mapping(address => string) public registeredTokenSymbols;

    /**
     * @notice Registers a token by fetching and storing its symbol.
     * @dev This function will revert if it cannot call `symbol()` on the token.
     */
    function registerToken(IERC20 token) public {
        string memory tokenSymbol = token.symbol();
        registeredTokenSymbols[address(token)] = tokenSymbol;
    }
}
