# Key Management Cheat Sheet

## Introduction

This Key Management Cheat Sheet provides developers with guidance for implementation of cryptographic key management within an application in a secure manner. It is important to document and harmonize rules and practices for:

1. Key life cycle management (generation, distribution, destruction)
2. Key compromise, recovery and zeroization
3. Key storage
4. Key agreement

## General Guidelines and Considerations

Formulate a plan for the overall organization's cryptographic strategy to guide developers working on different applications and ensure that each application's cryptographic capability meets minimum requirements and best practices.

Identify the cryptographic and key management requirements for your application and map all components that process or store cryptographic key material.

## Key Selection

Selection of the cryptographic and key management algorithms to use within a given application should begin with an understanding of the objectives of the application.

For example, if the application is required to store data securely, then the developer should select an algorithm suite that supports the objective of data at rest protection security. Applications that are required to transmit and receive data would select an algorithm suite that supports the objective of data in transit protection.

Once the understanding of the security needs of the application is achieved, developers can determine what protocols and algorithms are required. Once the protocols and algorithms are understood, you can begin to define the different types of keys that will support the application's objectives.

There are a diverse set of key types and certificates to consider, for example:

1. **Encryption:** Symmetric encryption keys, Asymmetric encryption keys (public and private).
2. **Authentication of End Devices:** Pre-shared symmetric keys, Trusted certificates, Trust Anchors.
3. **Data Origin Authentication:** HMAC.
4. **Integrity Protection:** Message Authentication Codes (MACs).
5. **Key Encryption Keys**.

### Algorithms and Protocols

According to `NIST SP 800-57 Part 1`, many algorithms and schemes that provide a security service use a hash function as a component of the algorithm.

`NIST SP 800-57 Part 1` recognizes three basic classes of approved cryptographic algorithms: hash functions, symmetric-key algorithms and asymmetric-key algorithms.

The NSA released a report, Commercial National Security Algorithm Suite 2.0 which lists the cryptographic algorithms that are expected to remain strong even with advances in quantum computing.

#### Cryptographic hash functions

Cryptographic hash functions do not require keys. Hash functions generate a relatively small digest from a (possibly) large input in a way that is fundamentally difficult to reverse. Hash functions are used as building blocks for key management:

1. To provide data authentication and integrity services.
2. To compress messages for digital signature generation and verification.
3. To derive keys in key-establishment algorithms.
4. To generate deterministic random numbers.

#### Symmetric-key algorithms

Symmetric-key algorithms (sometimes known as secret-key algorithms) transform data in a way that is fundamentally difficult to undo without knowledge of a secret key. The key is "symmetric" because the same key is used for a cryptographic operation and its inverse (e.g., encryption and decryption).

#### Asymmetric-key algorithms

Asymmetric-key algorithms, commonly known as public-key algorithms, use two related keys (i.e., a key pair) to perform their functions: a public key and a private key. The public key may be known by anyone; the private key should be under the sole control of the entity that "owns" the key pair.

#### Message Authentication Codes (MACs)

Message Authentication Codes (MACs) provide data authentication and integrity. A MAC is a cryptographic checksum on the data that is used in order to provide assurance that the data has not changed and that the MAC was computed by the expected entity.

#### Digital Signatures

Digital signatures are used to provide authentication, integrity and non-repudiation. `FIPS186` specifies algorithms that are approved for the computation of digital signatures.

#### Key Encryption Keys

Symmetric key-wrapping keys are used to encrypt other keys using symmetric-key algorithms. Key-wrapping keys are also known as key encrypting keys.

### Key Strength

Review `NIST SP 800-57` for recommended guidelines on key strength for specific algorithm implementations. Best practices:

1. Establish the application's minimum computational resistance to attack.
2. When encrypting keys for storage or distribution, always encrypt a cryptographic key with another key of equal or greater cryptographic strength.
3. When moving to Elliptic Curve-based algorithms, choose a key length that meets or exceeds the comparative strength of other algorithms in use within your system. Refer to `NIST SP 800-57 Table 2`.
4. Formulate a strategy for the overall organization's cryptographic strategy.

### Memory Management Considerations

Keys stored in memory for a long time can become "burned in". This can be mitigated by splitting the key into components that are frequently updated (`NIST SP 800-57`).

### Perfect Forward Secrecy

Ephemeral keys can provide perfect forward secrecy protection, which means a compromise of the server's long term signing key does not compromise the confidentiality of past sessions.

### Key Usage

According to NIST, in general, a single key should be used for only one purpose (e.g., encryption, authentication, key wrapping, random number generation, or digital signatures).

Reasons:
1. The use of the same key for two different cryptographic processes may weaken the security provided by one or both of the processes.
2. Limiting the use of a key limits the damage that could be done if the key is compromised.
3. Some uses of keys interfere with each other.

### Cryptographic Module Topics

According to `NIST SP 800-133`, cryptographic modules are the set of hardware, software, and/or firmware that implements security functions and is contained within a cryptographic module boundary to provide protection of the keys.

## Key Management Lifecycle Best Practices

### Generation

Cryptographic keys shall be generated within cryptographic module with at least a `FIPS 140-2 or 140-3` compliance.

Any random value required by the key-generating module shall be generated within that module; the Random Bit Generator shall be implemented within a FIPS 140-2/140-3 compliant module.

Hardware cryptographic modules are preferred over software cryptographic modules for protection.

### Distribution

The generated keys shall be transported (when necessary) using secure channels and shall be used by their associated cryptographic algorithm within at least a `FIPS 140-2 or 140-3` compliant cryptographic module.

### Storage

1. Understand where cryptographic keys are stored within the application.
2. Keys must be protected on both volatile and persistent memory, ideally processed within secure cryptographic modules.
3. Keys should never be stored in plaintext format.
4. Ensure all keys are stored in a cryptographic vault, such as a hardware security module (HSM) or isolated cryptographic service.
5. If storing keys in offline devices/databases, encrypt the keys using Key Encryption Keys (KEKs) prior to export. KEK length should be equivalent to or greater in strength than the keys being protected.
6. Ensure that keys have integrity protections applied while in storage.
7. Ensure that standard application level code never reads or uses cryptographic keys in any way — use key management libraries.
8. Ensure all work is done in the vault (key access, encryption, decryption, signing, etc).

### Escrow and Backup

Data that has been encrypted with lost cryptographic keys will never be recovered. It is essential that the application incorporate a secure key backup capability.

When backing up keys, ensure that the database used to store the keys is encrypted using at least a `FIPS 140-2 or 140-3` validated module.

Never escrow keys used for performing digital signatures, but consider the need to escrow keys that support encryption.

### Accountability and Audit

Accountability involves the identification of those that have access to, or control of, cryptographic keys throughout their lifecycles.

The key management system should account for all individuals who are able to view plaintext cryptographic keys.

Two types of audit should be performed on key management systems:
1. The security plan and procedures should be periodically audited.
2. The protective mechanisms employed should be periodically reassessed.

### Key Compromise and Recovery

The compromise of a key has significant implications including: unauthorized disclosure, integrity compromise, or association compromise. A compromise-recovery plan is essential for restoring cryptographic security services.

The compromise-recovery plan should contain:
1. The identification and contact info of the personnel to notify.
2. The identification and contact info of the personnel to perform the recovery actions.
3. The re-key method.
4. An inventory of all cryptographic keys and their use.
5. The education of all appropriate personnel on the recovery procedures.
6. Policies that key-revocation checking be enforced.
7. The monitoring of the re-keying operations.

## Trust Stores

1. Design controls to secure the trust store against injection of third-party root certificates.
2. Implement integrity controls on objects stored in the trust store.
3. Do not allow for export of keys held within the trust store without authentication and authorization.
4. Setup strict policies and procedures for exporting key material.
5. Implement a secure process for updating the trust store.

## Cryptographic Key Management Libraries

Use only reputable crypto libraries that are well maintained and updated, as well as tested and validated by third-party organizations (e.g., `NIST`/`FIPS`).
