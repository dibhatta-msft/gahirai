# Find a valid point on y^2 = x^3 + 7 mod 97 using plain integers

def is_quadratic_residue(n, p):
    n = n % p
    for y in range(p):
        if (y * y) % p == n:
            return y
    return None

def main():
    a = 0
    b = 7
    p = 97
    for x in range(p):
        rhs = (x ** 3 + a * x + b) % p
        y = is_quadratic_residue(rhs, p)
        if y is not None:
            print(f"Found point: x={x}, y={y}, y^2 mod p = {rhs}")
            break

if __name__ == "__main__":
    main()
