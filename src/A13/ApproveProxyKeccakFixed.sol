// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ApproveProxyKeccakFixed
 * @dev The corrected version of the contract.
 * It adds a require statement to block `address(0)` from being used as `_from`.
 */
contract ApproveProxyKeccakFixed {
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    string public constant name = "ApproveProxy";

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice The corrected meta-transaction approval function.
     * @dev CORRECTED: Explicitly checks for `_from != address(0)`.
     */
    function approveProxy(
        address _from,
        address _spender,
        uint256 _value,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool success) {
        // --- MITIGATION ---
        require(_from != address(0), "From address cannot be zero");

        uint256 nonce = nonces[_from];
        bytes32 hash = keccak256(
            abi.encodePacked(_from, _spender, _value, nonce, name)
        );

        if (_from != ecrecover(hash, _v, _r, _s)) {
            revert("Invalid signature");
        }

        allowance[_from][_spender] = _value;
        emit Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }

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
