# Citadel Protocol Integration: Architectural Design

## 1. Overview: A Symbiotic Architecture

The Citadel Protocol's vision of a user-owned internet is not an alternative to the Nexus Protocol; it is its highest expression. This document outlines a design to integrate the Citadel Protocol directly into the Nexus network, leveraging Nexus's robust, decentralized infrastructure to create a new paradigm of data sovereignty.

Nexus provides the **Sovereign Foundation** (the secure L1 blockchain and P2P network). The Citadel Protocol will be implemented as the **Sovereign Application Layer**, a set of core network services and smart contracts running on top of Nexus.

## 2. The Citadel: Sovereign Data Vaults on Nexus

A user's "Citadel" will not be a single physical or logical vault, but a distributed, encrypted data store managed by the Nexus network itself.

*   **Storage Backbone:** The existing **Nomad Network's Distributed Hash Table (DHT)** (`Storage/DHT.jl`) will serve as the storage fabric. When a user creates data (a post, a profile update, a private message), the data is encrypted locally, broken into chunks, and distributed across the Nomad swarm. No single node holds the complete data set.
*   **Sovereign Identity & Encryption:** The upcoming **`EmPower1` Identity Layer** (mentioned in the Nexus Roadmap) will be the cornerstone of the Citadel. A user's master cryptographic key, managed by `EmPower1`, is the only key that can encrypt and decrypt their Citadel data. This key *is* the user's sovereign identity. All data in a user's Citadel is encrypted with this key before it ever touches the network.
*   **Management:** The `forge-nexus` CLI will be extended with a `citadel` command set (e.g., `forge-nexus citadel upload`, `forge-nexus citadel grant`) for direct, command-line management of the user's data vault.

## 3. The Service Layer: Permissioned Access via Smart Contracts

This layer provides a trustless bridge for applications to interact with a user's Citadel without the user ever surrendering ownership of their data.

*   **Core Component:** The **WASM Virtual Machine** (`VM/WASM_Runtime.jl`) is the engine for the Service Layer. We will develop a standardized "Access Control" smart contract that will be deployed for every user.
*   **Permission Grants as Transactions:** When a dApp wishes to access a user's data, it initiates a special transaction on the Nexus network. This transaction calls the user's Access Control contract with a request for specific permissions (e.g., `scope: "read:profile,posts"`, `dApp_id: "DigiSocialBlock"`).
*   **User Authorization:** The user signs this permission-granting transaction with their `EmPower1` key. This action is an auditable, on-chain record that the user has consented to the access request. The Access Control contract updates its state to reflect this grant.
*   **Revocable Access:** Revoking access is as simple as sending a "revoke" transaction. The user signs a transaction that calls their Access Control contract, which removes the dApp's permissions from its state. The revocation is instant and absolute.
*   **Data Flow:**
    1.  A dApp requests data from the Nexus network.
    2.  The Nomad nodes first query the user's on-chain Access Control contract to verify the dApp has the appropriate permissions.
    3.  If permissions are valid, the Nomads retrieve the requested encrypted data chunks from the DHT and serve them to the dApp.
    4.  The dApp then requires the user (via their local client) to provide a temporary, session-specific decryption key to make the data readable. The master key is never exposed to the dApp.

## 4. Solving Web 2.0's Flaws

This integrated architecture directly addresses the core problems you outlined:

*   **Platform Lock-In:** A user can grant and revoke access to any number of competing dApps simultaneously. Their data, friends, and identity remain in their Citadel, seamlessly portable across the entire application ecosystem.
*   **Censorship & De-platforming:** A dApp can choose to stop rendering a user's data, but they can never delete it. The user's Citadel is part of the underlying Nexus network and remains intact, accessible via any other dApp the user grants permission to.
*   **Data Monetization (The Sovereign Exchange):** The Access Control smart contract can be extended to include payment clauses. A dApp's permission grant could require a micropayment in **NXS tokens** per query or per data item accessed. This creates a direct, peer-to-peer economy where users are paid for the use of their data, fulfilling the promise of the "Sovereign Exchange."

## 5. Conclusion

By implementing the Citadel Protocol on the Nexus network, we create a powerful symbiosis. Nexus provides the secure, decentralized world, and the Citadel Protocol makes it habitable for the sovereign individual. This design transforms Nexus from a simple blockchain into a true operating system for a new, user-owned internet.
