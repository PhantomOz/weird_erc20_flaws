// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CentralizedToken
 * @dev A token contract with a "God-mode" function that allows a central account
 * to transfer any user's tokens without their consent.
 */
contract CentralizedToken {
    mapping(address => uint256) public balances;
    address public centralAccount;

    event Transfer(address indexed from, address indexed to, uint256 value);

    modifier onlyCentralAccount() {
        require(
            msg.sender == centralAccount,
            "Caller is not the central account"
        );
        _;
    }

    constructor(address _centralAccount) {
        centralAccount = _centralAccount;
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    /**
     * @notice Allows the central account to move funds between any two users.
     * @dev VULNERABLE: This function grants absolute power over user funds to the
     * central account, breaking the principle of self-custody.
     */
    function zero_fee_transaction(
        address _from,
        address _to,
        uint256 _amount
    ) public onlyCentralAccount returns (bool success) {
        if (
            balances[_from] >= _amount &&
            balances[_to] + _amount >= balances[_to]
        ) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
}
