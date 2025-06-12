"""
Tests for the generic SNARK scaffold (toy SNARK example).
"""
from bigint.snark import EllipticCurve, ArithmeticCircuit, ToySNARKProver, ToySNARKVerifier
from bigint.bigint import BigInt

def test_toy_snark():
    curve = EllipticCurve(2, 3, 97)
    circuit = ArithmeticCircuit([(0, 1, 2), (2, 3, 4)])
    witness = [BigInt(3), BigInt(6), BigInt(18), BigInt(2), BigInt(36)]
    prover = ToySNARKProver(circuit, curve)
    proof = prover.prove(witness)
    verifier = ToySNARKVerifier(circuit, curve)
    assert verifier.verify(proof)
    print("Toy SNARK test passed.")

if __name__ == "__main__":
    test_toy_snark()
