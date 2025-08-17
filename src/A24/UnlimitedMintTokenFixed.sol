// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title UnlimitedMintTokenFixed
 * @dev The corrected contract with a properly secured minting function.
 */
contract UnlimitedMintTokenFixed {
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        // Mint an initial supply to the deployer (owner).
        totalSupply = 1000 * 1e18;
        balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @notice Mints new tokens and sends them to a specified address.
     * @dev CORRECTED: This function is now protected by `onlyOwner` and
     * correctly updates the totalSupply.
     * @param _to The address to receive the new tokens.
     * @param _value The amount of new tokens to mint.
     */
    function mint(address _to, uint256 _value) public onlyOwner {
        totalSupply += _value;
        balances[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }
}
