// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title PauseTransferAnyoneFixed
 * @dev This is the corrected version of the contract.
 * The onlyFromWallet modifier correctly uses '==' to ensure only the
 * designated walletAddress can pause/unpause transfers.
 */
contract PauseTransferAnyoneFixed is ERC20 {
    address public walletAddress;
    bool public tokenTransfer;
    mapping(address => bool) public unlockaddress;

    event TokenTransfer(bool enabled);

    modifier isTokenTransfer() {
        if (!tokenTransfer) {
            require(unlockaddress[msg.sender], "Transfers are paused");
        }
        _;
    }

    // --- MITIGATED MODIFIER ---
    // The logic is corrected to use '==' to ensure only walletAddress can call.
    modifier onlyFromWallet() {
        require(msg.sender == walletAddress, "Caller is not the admin");
        _;
    }

    constructor(address _walletAddress) ERC20("Fixed Token", "FIX") {
        walletAddress = _walletAddress;
        tokenTransfer = false;
        _mint(msg.sender, 1000 * 1e18);
    }

    function transfer(
        address to,
        uint256 amount
    ) public override isTokenTransfer returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override isTokenTransfer returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice Enables token transfers for everyone.
     * @dev CORRECTED: Can only be called by walletAddress.
     */
    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        emit TokenTransfer(true);
    }

    /**
     * @notice Disables token transfers for everyone.
     * @dev CORRECTED: Can only be called by walletAddress.
     */
    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        emit TokenTransfer(false);
    }
}
