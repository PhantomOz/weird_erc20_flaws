// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ApproveProxyKeccak
 * @dev A minimal token contract with a vulnerable `approveProxy` function.
 * It allows an attacker to approve themselves to spend tokens from address(0)
 * by providing an invalid signature.
 */
contract ApproveProxyKeccak {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    string public constant name = "ApproveProxy";

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @notice Mints tokens to an address. Only for test setup.
     */
    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice The vulnerable meta-transaction approval function.
     * @dev Does not check for `_from == address(0)`, making it exploitable.
     */
    function approveProxy(
        address _from,
        address _spender,
        uint256 _value,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool success) {
        uint256 nonce = nonces[_from];
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _spender, _value, nonce, name)
        );

        // --- VULNERABLE CHECK ---
        // If _from is address(0) and the signature is invalid, ecrecover returns
        // address(0), bypassing this check.
        if (_from != ecrecover(hash, _v, _r, _s)) {
            revert("Invalid signature");
        }

        allowance[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }

    /**
     * @notice A standard transferFrom function for the attacker to use post-exploit.
     */
    function transferFrom(address from, address to, uint256 amount) public {
        require(balances[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        balances[from] -= amount;
        balances[to] += amount;
        allowance[from][msg.sender] -= amount;
    }
}
