# ERC20 Weirdness: A Catalogue of Token Vulnerabilities

This repository is an interactive, hands-on catalogue of common, historical, and unusual vulnerabilities, design flaws, and non-compliance issues related to the ERC20 token standard. Each example includes a vulnerable contract, a mitigated/fixed version, and a proof-of-concept test written in Foundry to demonstrate the exploit and the fix.

The goal is to provide a practical learning resource for Web3 developers, security researchers, and auditors to understand these issues in a hands-on environment.

## Table of Contents

  - [Why This Repository?](#why-this-repository)
  - [Prerequisites](#prerequisites)
  - [Setup and Usage](#setup-and-usage)
  - [Vulnerability Catalogue](#vulnerability-catalogue)
      - [Section A: Functional Vulnerabilities](#section-a-functional-vulnerabilities)
      - [Section B: Standards Compliance Failures](#section-b-standards-compliance-failures)
      - [Section C: Centralization Risks](#section-c-centralization-risks)
  

## Why This Repository?

The ERC20 standard is the bedrock of DeFi, but its simplicity hides a landscape of potential pitfalls. Studying these "weirdnesses" is crucial for:

  - **Secure Development:** Learn what to avoid when building your own tokens or contracts that interact with them.
  - **Security Auditing:** Quickly recognize common anti-patterns and vulnerabilities during code reviews.
  - **Historical Context:** Understand historical hacks and design choices that have shaped the current best practices.

## Prerequisites

You will need [Foundry](https://book.getfoundry.sh/getting-started/installation) installed to run the tests in this repository.

## Setup and Usage

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/PhantomOz/weird_erc20_flaws.git
    cd weird_erc20_flaws
    ```

2.  **Install dependencies:**
    This project uses `openzeppelin-contracts` which Foundry will install automatically.

    ```bash
    forge install
    ```

3.  **Run all tests:**
    To run the entire test suite and verify all exploits and mitigations:

    ```bash
    forge test
    ```

4.  **Run a specific test:**
    To focus on a single vulnerability, you can run a specific test file. This is the recommended way to learn. For example, to test the issue in section `A11`:

    ```bash
    forge test --match-path test/A11.t.sol -vv
    ```

-----

## Vulnerability Catalogue

### Section A: Functional Vulnerabilities

#### A11: `pauseTransfer-anyone`

  - **Description:** A logical error (`!=` instead of `==`) in a modifier gives administrative control (pausing transfers) to every user *except* the intended admin.
  - **Impact:** Any user can disrupt the token's functionality by enabling or disabling transfers at will.
  - **Files:**
      - Vulnerable: [`src/A11/PauseTransferAnyone.sol`](./src/A11/PauseTransferAnyone.sol)
      - Fixed: [`src/A11/PauseTransferAnyoneFixed.sol`](./src/A11/PauseTransferAnyoneFixed.sol)
      - Test: [`test/A11.t.sol`](./test/A11.t.sol)

#### A12: `transferProxy-keccak256`

  - **Description:** The `ecrecover` function returns `address(0)` for invalid signatures. A missing check for `_from != address(0)` allows an attacker to bypass signature verification and perform actions on behalf of the zero address.
  - **Impact:** Theft of any tokens held by the `address(0)`.
  - **Files:**
      - Vulnerable: [`src/A12/TransferProxyKeccak.sol`](./src/A12/TransferProxyKeccak.sol)
      - Fixed: [`src/A12/TransferProxyKeccakFixed.sol`](./src/A12/TransferProxyKeccakFixed.sol)
      - Test: [`test/A12.t.sol`](./test/A12.t.sol)

#### A13: `approveProxy-keccak256`

  - **Description:** Identical to A12, but the vulnerability is in an `approveProxy` function.
  - **Impact:** Attacker can grant themselves an unlimited allowance to spend tokens from `address(0)`, leading to theft.
  - **Files:**
      - Vulnerable: [`src/A13/ApproveProxyKeccak.sol`](./src/A13/ApproveProxyKeccak.sol)
      - Fixed: [`src/A13/ApproveProxyKeccakFixed.sol`](./src/A13/ApproveProxyKeccakFixed.sol)
      - Test: [`test/A13.t.sol`](./test/A13.t.sol)

#### A15: `custom-fallback-bypass-ds-auth`

  - **Description:** A combination of a flawed authorization system that trusts calls from the contract itself (`msg.sender == address(this)`) and a function that allows for arbitrary external calls.
  - **Impact:** An attacker can make the contract call itself to execute a privileged function, bypassing authorization and taking ownership.
  - **Files:**
      - Vulnerable: [`src/A15/CustomFallbackToken.sol`](./src/A15/CustomFallbackToken.sol)
      - Fixed: [`src/A15/CustomFallbackTokenFixed.sol`](./src/A15/CustomFallbackTokenFixed.sol)
      - Test: [`test/A15.t.sol`](./test/A15.t.sol)

#### A16: `custom-call-abuse`

  - **Description:** The contract exposes a generic "proxy" function that allows anyone to execute an arbitrary call to any target.
  - **Impact:** Catastrophic. An attacker can use this to steal any tokens *owned by* or *approved to* the vulnerable contract.
  - **Files:**
      - Vulnerable: [`src/A16/CustomCallAbuse.sol`](./src/A16/CustomCallAbuse.sol)
      - Fixed: [`src/A16/CustomCallAbuseFixed.sol`](./src/A16/CustomCallAbuseFixed.sol)
      - Test: [`test/A16.t.sol`](./test/A16.t.sol)

#### A17: `setowner-anyone`

  - **Description:** A critical administrative function, `setOwner`, has no access control.
  - **Impact:** Any user can call `setOwner` at any time and take complete control of the contract.
  - **Files:**
      - Vulnerable: [`src/A17/UnprotectedOwner.sol`](./src/A17/UnprotectedOwner.sol)
      - Fixed: [`src/A17/UnprotectedOwnerFixed.sol`](./src/A17/UnprotectedOwnerFixed.sol)
      - Test: [`test/A17.t.sol`](./test/A17.t.sol)


#### A19: `approve-with-balance-verify`

  - **Description:** The `approve` function contains a non-standard check requiring the approval amount to be less than or equal to the user's current balance.
  - **Impact:** A design flaw, not a theft vector. It breaks compatibility with standard DeFi patterns like "infinite approval," rendering the token unusable with many protocols.
  - **Files:**
      - Vulnerable: [`src/A19/RestrictiveApprovalToken.sol`](./src/A19/RestrictiveApprovalToken.sol)
      - Fixed: [`src/A19/RestrictiveApprovalTokenFixed.sol`](./src/A19/RestrictiveApprovalTokenFixed.sol)
      - Test: [`test/A19.t.sol`](./test/A19.t.sol)

#### A20: `re-approve`

  - **Description:** The classic ERC20 `approve` race condition. A malicious spender can front-run a user's transaction to change an allowance, allowing them to spend both the old and new amounts.
  - **Impact:** A user can lose more tokens than intended when adjusting an existing approval.
  - **Files:**
      - Vulnerable: [`src/A20/ReApproveToken.sol`](./src/A20/ReApproveToken.sol)
      - Fixed: [`src/A20/ReApproveTokenFixed.sol`](./src/A20/ReApproveTokenFixed.sol)
      - Test: [`test/A20A21.t.sol`](./test/A20A21.t.sol)

#### A21: `check-effect-inconsistency`

  - **Description:** A logic error where the contract checks one user's allowance but decrements a different user's allowance.
  - **Impact:** A spender with a valid allowance can use it an infinite number of times, as their own allowance is never consumed.
  - **Files:**
      - Vulnerable: [`src/A21/InconsistentToken.sol`](./src/A21/InconsistentToken.sol)
      - Fixed: [`src/A21/InconsistentTokenFixed.sol`](./src/A21/InconsistentTokenFixed.sol)
      - Test: [`test/A20A21.t.sol`](./test/A20A21.t.sol)

#### A22: `constructor-mistyping`

  - **Description:** An initializer function, meant to be called only once at deployment, is left unprotected. This is the modern equivalent of historical constructor-naming bugs.
  - **Impact:** An attacker can call the initializer after deployment to re-assign critical roles like `owner`, leading to a contract takeover.
  - **Files:**
      - Vulnerable: [`src/A22/MistypedConstructor.sol`](./src/A22/MistypedConstructor.sol)
      - Fixed: [`src/A22/MistypedConstructorFixed.sol`](./src/A22/MistypedConstructorFixed.sol)
      - Test: [`test/A22A23.t.sol`](./test/A22A23.t.sol)


#### A24: `getToken-anyone`

  - **Description:** A public, unprotected minting function allows any user to create new tokens for themselves at will.
  - **Impact:** Catastrophic. The token's supply can be infinitely inflated, destroying its economic value for all legitimate holders.
  - **Files:**
      - Vulnerable: [`src/A24/UnlimitedMintToken.sol`](./src/A24/UnlimitedMintToken.sol)
      - Fixed: [`src/A24/UnlimitedMintTokenFixed.sol`](./src/A24/UnlimitedMintTokenFixed.sol)
      - Test: [`test/A24.t.sol`](./test/A24.t.sol)

-----

### Section B: Standards Compliance Failures

These issues break interoperability with other smart contracts and ecosystem tools (wallets, explorers).

#### B1, B2, B3: `transfer`, `approve`, `transferFrom` - no-return

  - **Description:** The core functions of the ERC20 standard (`transfer`, `approve`, `transferFrom`) fail to include the required `returns (bool success)` in their signature.
  - **Impact:** Any compliant smart contract that calls these functions will have its transaction reverted, making the token unusable in the DeFi ecosystem.
  - **Files:**
      - B1: [`src/B1/`](https://www.google.com/search?q=./src/B1/), [`test/B1.t.sol`](https://www.google.com/search?q=./test/B1.t.sol)
      - B2: [`src/B2/`](https://www.google.com/search?q=./src/B2/), [`test/B2.t.sol`](https://www.google.com/search?q=./test/B2.t.sol)
      - B3: [`src/B3/`](https://www.google.com/search?q=./src/B3/), [`test/B3.t.sol`](https://www.google.com/search?q=./test/B3.t.sol)

#### B4, B5, B6: `no-decimals`, `no-name`, `no-symbol`

  - **Description:** The optional but universally expected ERC20 metadata variables (`decimals`, `name`, `symbol`) are implemented with non-standard, case-sensitive names (e.g., `DECIMALS` instead of `decimals`).
  - **Impact:** Wallets and explorers cannot display the token's information correctly. On-chain protocols that try to read this metadata will have their calls reverted.
  - **Files:**
      - B4: [`src/B4/`](https://www.google.com/search?q=./src/B4/), [`test/B4.t.sol`](https://www.google.com/search?q=./test/B4.t.sol)
      - B5: [`src/B5/`](https://www.google.com/search?q=./src/B5/), [`test/B5.t.sol`](https://www.google.com/search?q=./test/B5.t.sol)
      - B6: [`src/B6/`](https://www.google.com/search?q=./src/B6/), [`test/B6.t.sol`](https://www.google.com/search?q=./test/B6.t.sol)

#### B7: `no-Approval`

  - **Description:** The `approve` function correctly sets the allowance but fails to emit the required `Approval` event.
  - **Impact:** Off-chain services (wallets, indexers, explorers) will not detect that an approval has been set, leading to a broken and confusing user experience.
  - **Files:**
      - Vulnerable: [`src/B7/NoApprovalEventToken.sol`](https://www.google.com/search?q=./src/B7/NoApprovalEventToken.sol)
      - Fixed: [`src/B7/NoApprovalEventTokenFixed.sol`](https://www.google.com/search?q=./src/B7/NoApprovalEventTokenFixed.sol)
      - Test: [`test/B7.t.sol`](https://www.google.com/search?q=./test/B7.t.sol)

-----

### Section C: Centralization Risks

#### C1: `centralAccount-transfer-anyone`

  - **Description:** A privileged "central account" has a "God-mode" function that allows it to transfer tokens from any user's account without their consent.
  - **Impact:** A complete violation of self-custody. A malicious or compromised central account owner can steal funds from any user at will, rendering the token's decentralization a facade.
  - **Files:**
      - Vulnerable: [`src/C1/CentralizedToken.sol`](https://www.google.com/search?q=./src/C1/CentralizedToken.sol)
      - Fixed: [`src/C1/CentralizedTokenFixed.sol`](https://www.google.com/search?q=./src/C1/CentralizedTokenFixed.sol)
      - Test: [`test/C1.t.sol`](https://www.google.com/search?q=./test/C1.t.sol)
