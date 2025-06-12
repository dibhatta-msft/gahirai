"""
Tests for the minimal zk-STARK module (proof of knowledge of a secret).
"""
from bigint.stark import SimpleHash, STARKProver, STARKVerifier

def test_stark():
    p = 97
    hash_func = SimpleHash(p)
    secret = 42
    public_hash = hash_func.hash(hash_func.hash(hash_func.hash(hash_func.hash(hash_func.hash(secret)))))
    prover = STARKProver(None, None)
    proof = prover.prove(secret, hash_func)
    verifier = STARKVerifier(None, None)
    assert verifier.verify(public_hash, proof, hash_func)
    print("STARK test passed.")

if __name__ == "__main__":
    test_stark()
