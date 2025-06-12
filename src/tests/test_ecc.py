"""
Basic tests for the ECC module using BigInt.
"""
from bigint.ecc import EllipticCurve, Point

def main():
    # Example: y^2 = x^3 + 2x + 3 mod 97
    a = 2
    b = 3
    p = 97  # Use a small prime for demonstration
    curve = EllipticCurve(a, b, p)
    # G = (3, 6) is on the curve: 6^2 % 97 = 36, (3^3 + 2*3 + 3) % 97 = 36
    G = Point(curve, 3, 6)
    # Debug: print the left and right sides of the curve equation
    left = (G.y * G.y) % curve.p
    right = (G.x * G.x * G.x + curve.a * G.x + curve.b) % curve.p
    print(f"left (y^2 mod p) = {left}")
    print(f"right (x^3 + ax + b mod p) = {right}")
    print(f"G = ({G.x}, {G.y})")
    print(f"curve.p = {curve.p}")
    assert curve.is_on_curve(G)
    print(f"G = ({G.x}, {G.y}) is on curve: {curve.is_on_curve(G)}")
    P = 2 * G
    print(f"2G = ({P.x}, {P.y})")
    Q = 3 * G
    print(f"3G = ({Q.x}, {Q.y})")
    print(f"O (infinity) + G = {Point(curve) + G}")
    print(f"G + O (infinity) = {G + Point(curve)}")
    print(f"-G = ({(-G).x}, {(-G).y})")
    print(f"G + (-G) = {G + (-G)} (should be infinity)")

if __name__ == "__main__":
    main()
