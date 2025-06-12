"""
A simple interactive web app to play with BigInt, ECC, and ZK concepts.
Run with: streamlit run src/app/app.py
"""
import streamlit as st
from bigint.bigint import BigInt
from bigint.ecc import EllipticCurve, Point

st.title("Crypto Playground: BigInt, ECC, and ZK")

st.header("BigInt Playground")
a = st.text_input("Enter first big integer (a):", "123456789123456789123456789")
b = st.text_input("Enter second big integer (b):", "987654321987654321987654321")
if st.button("Compute a + b, a * b"):
    try:
        a_big = BigInt(a)
        b_big = BigInt(b)
        st.write(f"a + b = {a_big + b_big}")
        st.write(f"a * b = {a_big * b_big}")
    except Exception as e:
        st.error(f"Error: {e}")

st.header("ECC Playground")
p = st.text_input("Field prime p:", "97")
a_curve = st.text_input("Curve a:", "2")
b_curve = st.text_input("Curve b:", "3")
x = st.text_input("Point x:", "3")
y = st.text_input("Point y:", "6")
if st.button("Check if point is on curve"):
    try:
        curve = EllipticCurve(a_curve, b_curve, p)
        P = Point(curve, x, y)
        st.write(f"Is ({x}, {y}) on the curve? {curve.is_on_curve(P)}")
    except Exception as e:
        st.error(f"Error: {e}")

st.header("ECDH Demo")
if st.button("Generate ECDH Key Exchange (toy curve)"):
    try:
        curve = EllipticCurve(a_curve, b_curve, p)
        G = Point(curve, x, y)
        priv1 = BigInt(5)
        priv2 = BigInt(7)
        pub1 = G * priv1
        pub2 = G * priv2
        shared1 = pub2 * priv1
        shared2 = pub1 * priv2
        st.write(f"Party 1 public: ({pub1.x}, {pub1.y})")
        st.write(f"Party 2 public: ({pub2.x}, {pub2.y})")
        st.write(f"Shared secret 1: ({shared1.x}, {shared1.y})")
        st.write(f"Shared secret 2: ({shared2.x}, {shared2.y})")
        st.write(f"Match? {shared1.x == shared2.x and shared1.y == shared2.y}")
    except Exception as e:
        st.error(f"Error: {e}")

st.info("This is a toy demo. For real cryptography, use secure, audited libraries and large, standard curves!")
