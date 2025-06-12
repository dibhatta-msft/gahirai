"""
Educational example of a TLS-like handshake using ECC and BigInt.
This demonstrates ECDH key exchange and shared secret derivation.
"""
from bigint.ecc import EllipticCurve, Point
from bigint.bigint import BigInt
import random

# secp256k1 parameters
SECP256K1_P = BigInt(int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F", 16))
SECP256K1_A = BigInt(0)
SECP256K1_B = BigInt(7)
SECP256K1_Gx = BigInt(int("0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", 16))
SECP256K1_Gy = BigInt(int("0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", 16))
SECP256K1_ORDER = BigInt(int("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", 16))

# Use the secp256k1 curve
def get_curve():
    return EllipticCurve(SECP256K1_A, SECP256K1_B, SECP256K1_P)

# Generate ECC key pair (private, public)
def generate_keypair(curve, G, order):
    priv = BigInt(random.randint(1, int(str(order)) - 1))
    pub = G * priv  # Correct order for scalar multiplication
    return priv, pub

def ecdh_shared_secret(priv, pub_other, curve):
    # Shared secret is pub_other * priv
    S = pub_other * priv
    print(f"DEBUG: shared point: ({S.x}, {S.y})")
    # Print the input values for debugging
    print(f"DEBUG: priv: {priv}, pub_other: ({pub_other.x}, {pub_other.y})")
    return S.x

def point_order(P):
    Q = P
    order = 1
    while not Q.is_infinity():
        try:
            Q = Q + P
        except ZeroDivisionError:
            break
        order += 1
        if order > 500:  # Avoid infinite loop on bad curves
            break
    return order

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0:
            return False
    return True

def find_prime_order_point(curve, max_xy=200):
    for x in range(max_xy-1, 0, -1):
        for y in range(max_xy-1, 0, -1):
            P = Point(curve, x, y)
            if curve.is_on_curve(P):
                order = point_order(P)
                if is_prime(order) and order > 5:
                    print(f"Found point of prime order: ({x}, {y}), order: {order}")
                    return P, order
    print("No point of small prime order found in extended range.")
    return None, None

def test_scalar_multiplication(curve, G, order):
    import random
    a = BigInt(random.randint(1, int(str(order)) - 1))
    b = BigInt(random.randint(1, int(str(order)) - 1))
    P1 = G * a
    P2 = G * b
    left = P2 * a
    right = P1 * b
    print(f"Test: (G * a) * b = (G * b) * a ?\nleft: ({left.x}, {left.y})\nright: ({right.x}, {right.y})")
    assert left == right, "Scalar multiplication is incorrect!"
    print("Scalar multiplication test passed.")

def main():
    curve = get_curve()
    G = Point(curve, SECP256K1_Gx, SECP256K1_Gy)
    order = SECP256K1_ORDER
    print(f"Using secp256k1 generator: ({G.x}, {G.y}), order: {order}")
    test_scalar_multiplication(curve, G, order)
    # Server generates key pair
    server_priv, server_pub = generate_keypair(curve, G, order)
    # Client generates key pair
    client_priv, client_pub = generate_keypair(curve, G, order)
    print(f"Server public key: ({server_pub.x}, {server_pub.y})")
    print(f"Client public key: ({client_pub.x}, {client_pub.y})")
    # Exchange public keys and compute shared secret
    server_secret = ecdh_shared_secret(server_priv, client_pub, curve)
    client_secret = ecdh_shared_secret(client_priv, server_pub, curve)
    print(f"Server derived secret: {server_secret}")
    print(f"Client derived secret: {client_secret}")
    assert server_secret == client_secret
    print("ECDH handshake successful! Shared secret established.")

if __name__ == "__main__":
    main()
