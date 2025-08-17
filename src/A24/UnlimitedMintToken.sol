// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UnlimitedMintToken
 * @dev A token contract with a public minting function `getToken` that
 * allows anyone to create an infinite number of tokens for themselves.
 */
contract UnlimitedMintToken {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        // Mint an initial supply to the deployer.
        totalSupply = 1000 * 1e18;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @notice Mints new tokens for the caller.
     * @dev VULNERABLE: This function is public with no access control.
     * It also fails to update the totalSupply.
     * @param _value The amount of new tokens to mint.
     */
    function getToken(uint256 _value) public returns (bool success) {
        balances[msg.sender] += _value;
        // FLAW: totalSupply is not updated.
        emit Transfer(address(0), msg.sender, _value);
        return true;
    }
}
