// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title PauseTransferAnyone
 * @dev An ERC20 token with a flawed transfer pausing mechanism.
 * The onlyFromWallet modifier mistakenly uses '!=' instead of '==',
 * allowing anyone except the designated walletAddress to pause/unpause transfers.
 */
contract PauseTransferAnyone is ERC20 {
    address public walletAddress;
    bool public tokenTransfer;

    // This mapping is part of the provided snippet but is not a robust
    // way to handle whitelisting. Included for faithfulness to the example.
    mapping(address => bool) public unlockaddress;

    event TokenTransfer(bool enabled);

    modifier isTokenTransfer() {
        if (!tokenTransfer) {
            // Even when paused, allow whitelisted addresses to transact.
            require(unlockaddress[msg.sender], "Transfers are paused");
        }
        _;
    }

    // --- VULNERABLE MODIFIER ---
    // This modifier should ONLY allow walletAddress to call.
    // Due to the '!=' operator, it allows ANYONE EXCEPT walletAddress.
    modifier onlyFromWallet() {
        require(
            msg.sender != walletAddress,
            "Incorrect logic: allows anyone but admin"
        );
        _;
    }

    constructor(address _walletAddress) ERC20("Vulnerable Token", "VUL") {
        walletAddress = _walletAddress;
        // Start with transfers paused.
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
     * @dev VULNERABLE: Can be called by any address except walletAddress.
     */
    function enableTokenTransfer() external onlyFromWallet {
        tokenTransfer = true;
        emit TokenTransfer(true);
    }

    /**
     * @notice Disables token transfers for everyone.
     * @dev VULNERABLE: Can be called by any address except walletAddress.
     */
    function disableTokenTransfer() external onlyFromWallet {
        tokenTransfer = false;
        emit TokenTransfer(false);
    }
}
