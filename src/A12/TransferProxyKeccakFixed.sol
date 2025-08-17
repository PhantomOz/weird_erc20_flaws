// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TransferProxyKeccakFixed
 * @dev This is the corrected version of the contract.
 * It adds a require statement to block `address(0)` from being used as `_from`.
 */
contract TransferProxyKeccakFixed is ERC20 {
    string public constant proxyName = "TransferProxy";
    mapping(address => uint256) public nonce;

    constructor() ERC20("Fixed Proxy", "FPX") {
        _mint(msg.sender, 1_000_000 * 1e18);
    }

    /**
     * @notice A meta-transaction function to transfer tokens on behalf of `_from`.
     * @dev CORRECTED: Explicitly checks for `_from != address(0)`.
     */
    function transferProxy(
        address _from,
        address _to,
        uint256 _value,
        uint256 _feeMesh,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        // --- MITIGATION ---
        // Explicitly prevent the zero address from being used as the sender.
        require(_from != address(0), "From address cannot be zero");

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

        if (_from != ecrecover(h, _v, _r, _s)) {
            revert("Invalid signature");
        }

        nonce[_from]++;
        _update(_from, _to, _value);

        return true;
    }
}
