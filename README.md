# gahirai

A modular cryptographic library for infinite precision arithmetic, elliptic curve cryptography, and zero-knowledge proofs (zk-SNARKs and zk-STARKs) in Python.

## Features
- **BigInt**: Infinite precision integer arithmetic for cryptographic applications.
- **ECC**: Elliptic curve cryptography over arbitrary fields using BigInt.
- **SNARK**: Generic zk-proof scaffold and a toy SNARK implementation.
- **STARK**: Minimal, transparent zk-STARK proof of knowledge of a secret (no trusted setup).
- **Groth16**: Minimal Groth16 zk-SNARK scaffold (with trusted setup, see `trusted_setup.md`).

## Quick Start
Clone the repo and run the test scripts for each module:

```bash
python3 -m bigint.test_bigint   # Test BigInt arithmetic
python3 -m bigint.test_ecc      # Test ECC operations
python3 -m bigint.test_snark    # Test toy SNARK
python3 -m bigint.test_stark    # Test minimal STARK
```

## Example: Infinite Precision Arithmetic
```python
from bigint.bigint import BigInt
x = BigInt('123456789123456789123456789')
y = BigInt('987654321987654321987654321')
print(x + y)
print(x * y)
```

## Example: Elliptic Curve Point Operations
```python
from bigint.ecc import EllipticCurve, Point
curve = EllipticCurve(2, 3, 97)
G = Point(curve, 3, 6)
P = 2 * G
print(P.x, P.y)
```

## Example: zk-STARK Proof of Knowledge
```python
from bigint.stark import SimpleHash, STARKProver, STARKVerifier
p = 97
hash_func = SimpleHash(p)
secret = 42
public_hash = hash_func.hash(hash_func.hash(hash_func.hash(hash_func.hash(hash_func.hash(secret)))))
prover = STARKProver(None, None)
proof = prover.prove(secret, hash_func)
verifier = STARKVerifier(None, None)
print(verifier.verify(public_hash, proof, hash_func))
```

## Example: Groth16 zk-SNARK (Demo)
```python
from bigint.groth16 import Groth16TrustedSetup, Groth16Prover, Groth16Verifier
from bigint.snark import ArithmeticCircuit
from bigint.ecc import EllipticCurve
from bigint.bigint import BigInt
curve = EllipticCurve(2, 3, 97)
srs = Groth16TrustedSetup(curve, 5)
circuit = ArithmeticCircuit([(0, 1, 2), (2, 3, 4)])
witness = [BigInt(3), BigInt(6), BigInt(18), BigInt(2), BigInt(36)]
prover = Groth16Prover(circuit, curve, srs)
proof = prover.prove(witness)
verifier = Groth16Verifier(circuit, curve, srs)
print(verifier.verify([], proof))
```

## Running Example Scripts

To run example scripts (such as the TLS handshake demo), use the `-m` flag from the root of your workspace to ensure Python treats `bigint` as a package:

```bash
python -m bigint.tls_handshake
```

This avoids import errors like `ModuleNotFoundError: No module named 'bigint.ecc'`.

## Trusted Setup for Groth16
See [`bigint/trusted_setup.md`](bigint/trusted_setup.md) for details on the trusted setup procedure required by Groth16.

---
This library is for educational and prototyping purposes. Do not use in production without a thorough security review.
