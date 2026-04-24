# Package Signing and Verification

## Introduction

This tutorial demonstrates how to sign Zarf packages and verify their signatures to ensure package integrity and authenticity. The process involves generating cryptographic keys, signing packages during creation, verifying signatures, and deploying signed packages with verification enabled.

Package signing is a critical security practice, allowing you to verify that packages have not been tampered with and come from a trusted source.

## Prerequisites

- Zarf binary installed and accessible via command line
- Zarf source code repository (for the wordpress example package)
- A Kubernetes cluster (optional, needed only for deployment step)

## Step-by-Step Process

### Generate a Signing Key Pair

Execute the command to create cryptographic keys:

```
zarf tools gen-key
```

You'll be prompted to enter a password for encrypting the private key. This process generates two files:

- `cosign.key` - Private signing key (must be kept secure)
- `cosign.pub` - Public verification key (can be shared)

**Important:** Keep your private key secure and never commit it to version control. Anyone with access to your private key can sign packages as you.

### Create a Package

Build a wordpress package from the examples:

```
zarf package create ./zarf/examples/wordpress
```

The output will display the package filename and location.

### Sign the Package

Apply a digital signature using your private key:

```
zarf package sign zarf-package-wordpress-arm64-26.0.0.tar.zst \
  --signing-key cosign.key \
  --signing-key-password <password>
```

### Verify the Signature

Confirm package authenticity and integrity:

```
zarf package verify zarf-package-wordpress-amd64-26.0.0.tar.zst \
  --key cosign.pub
```

Successful verification outputs: "checksum verification status=PASSED" and "signature verification status=PASSED," confirming the package is authentic and unmodified.

### Deploy with Verification

Deploy the signed package with mandatory signature verification:

```
zarf package deploy zarf-package-wordpress-amd64-26.0.0.tar.zst \
  --key cosign.pub \
  --verify \
  --confirm
```

The `--verify` flag ensures deployment fails if signature validation is unsuccessful.

## Next Steps

- Review comprehensive signing documentation
- Explore cloud KMS options for production environments
- Integrate signature verification into CI/CD workflows
- Establish organizational key management procedures
