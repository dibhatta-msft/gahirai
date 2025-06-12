"""
Basic tests and demo for the BigInt class.
"""
from bigint import BigInt

def main():
    a = BigInt('123456789123456789123456789')
    b = BigInt('987654321987654321987654321')
    print(f"a = {a}")
    print(f"b = {b}")
    print(f"a + b = {a + b}")
    print(f"b - a = {b - a}")
    print(f"a * b = {a * b}")
    print(f"-a = {-a}")
    print(f"a == b: {a == b}")
    print(f"a < b: {a < b}")
    print(f"a > b: {a > b}")

if __name__ == "__main__":
    main()
