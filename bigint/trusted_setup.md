# Groth16 Trusted Setup Procedure

Groth16 is a zk-SNARK protocol that requires a trusted setup phase to generate public parameters. This setup is critical for the security of the system. Here is a high-level overview of the procedure:

## 1. Define the Circuit
- Specify the arithmetic circuit or Rank-1 Constraint System (R1CS) that you want to prove statements about.

## 2. Choose a Secret (Toxic Waste)
- Select a random secret value (often denoted as `s`). This value must be destroyed after setup to ensure security.

## 3. Generate Structured Reference String (SRS)
- Compute a set of elliptic curve group elements based on the secret `s` and the circuit:
  - Powers of `s` in both G1 and G2 groups (e.g., [1, s, s^2, ..., s^n]).
  - Additional elements for circuit-specific polynomials.
- The SRS consists of these group elements and is made public.

## 4. Discard the Secret
- The secret `s` (toxic waste) must be securely deleted. If it is ever revealed, the security of all proofs is compromised.

## 5. Multi-Party Computation (Optional)
- To avoid trusting a single party, a multi-party computation (MPC) ceremony can be used. Each participant contributes randomness, and as long as one participant is honest and deletes their secret, the setup remains secure.

## 6. Use the SRS
- The SRS is used by provers and verifiers in the Groth16 protocol to generate and verify proofs.

---

**Warning:** If the toxic waste is not destroyed or is leaked, anyone can create fake proofs. Always use a secure, auditable setup process.
