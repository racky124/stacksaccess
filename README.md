# StacksAccess Smart Contract

## Description

The **StacksAccess Smart Contract** provides an on-chain access control system built with Clarity for the Stacks blockchain. It enables permissioned access to decentralized content, features, or services—based on either direct address assignment or token ownership. This contract is ideal for gating premium features, token-gated content, or role-based application logic in decentralized applications (dApps).

## Features

- 🔐 **Permissioned Access:** Grant or revoke access to specific addresses.
- 🪙 **Token-Gated Access (Optional):** Enable access based on ownership of specific tokens.
- 🧑‍💼 **Admin Control:** Only designated admin(s) can manage access rights.
- 🕵️ **Access Verification:** Functions to check if a user has valid access.
- 📜 **On-Chain Records:** Fully auditable access management and logic enforcement.

## Core Functions

- `grant-access`: Admin-only function to assign access rights to a user.
- `revoke-access`: Admin-only function to remove access from a user.
- `has-access`: Public view to check if an address has access.
- `set-admin`: Admin function to transfer or assign admin privileges.
- `enable-token-gating` *(optional)*: Enable access based on ownership of a specific token.

## Setup & Testing

This contract is built using [Clarinet](https://docs.stacks.co/docs/clarity/clarinet/overview/), the official development toolchain for Clarity smart contracts.

### Run Tests

```bash
clarinet test
