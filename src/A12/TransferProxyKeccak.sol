// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TransferProxyKeccak
 * @dev An ERC20 token with a vulnerable `transferProxy` function.
 * It fails to check if the `_from` address is the zero address before
 * signature verification, allowing an attacker to bypass `ecrecover`
 * by providing an invalid signature and setting `_from` to address(0).
 */
contract TransferProxyKeccak is ERC20 {
    // A name for signature verification, similar to EIP-712.
    string public constant proxyName = "TransferProxy";
    // Nonce to prevent replay attacks.
    mapping(address => uint256) public nonce;

    constructor() ERC20("Vulnerable Proxy", "VPX") {
        // Mint the total supply to the zero address to simulate a honeypot.
        _mint(msg.sender, 1_000_000 * 1e18);
    }

    /**
     * @notice A meta-transaction function to transfer tokens on behalf of `_from`.
     * @dev VULNERABLE: Does not check for `_from == address(0)`.
     */
    function transferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh, // Included for faithfulness to the example
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        bytes32 h = keccak256(
            abi.encodePacked(
                _from,
                _to,
                _value,
                _feeMesh,
                nonce[_from],
                proxyName
            )
        );

        // --- VULNERABLE CHECK ---
        // If _from is address(0) and the signature is invalid, ecrecover returns
        // address(0), bypassing this check.
        if (_from != ecrecover(h, _v, _r, _s)) {
            revert("Invalid signature");
        }

        // Increment nonce to prevent replay.
        nonce[_from]++;

        // Execute the transfer.
        _update(_from, _to, _value);

        return true;
    }
}
