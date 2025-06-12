"""
Elliptic Curve Cryptography (ECC) module using BigInt for infinite precision arithmetic.
"""
from .bigint import BigInt

class EllipticCurve:
    def __init__(self, a, b, p):
        self.a = BigInt(a)
        self.b = BigInt(b)
        self.p = BigInt(p)

    def is_on_curve(self, point):
        if point.is_infinity():
            return True
        x, y = point.x, point.y
        return (y * y - (x * x * x + self.a * x + self.b)) % self.p == 0

class Point:
    def __init__(self, curve, x=None, y=None):
        self.curve = curve
        if x is None and y is None:
            self.x = None
            self.y = None
        else:
            self.x = BigInt(x)
            self.y = BigInt(y)

    def is_infinity(self):
        return self.x is None and self.y is None

    def __eq__(self, other):
        if self.is_infinity() and other.is_infinity():
            return True
        if self.is_infinity() or other.is_infinity():
            return False
        return self.x == other.x and self.y == other.y and self.curve == other.curve

    def __neg__(self):
        if self.is_infinity():
            return self
        return Point(self.curve, self.x, (-self.y) % self.curve.p)

    def __add__(self, other):
        if self.is_infinity():
            return other
        if other.is_infinity():
            return self
        if self.x == other.x and (self.y != other.y or self.y == 0):
            return Point(self.curve)  # Point at infinity
        p = self.curve.p
        if self.x == other.x:
            # Point doubling
            l = (3 * self.x * self.x + self.curve.a) * self._inv(2 * self.y, p) % p
        else:
            # Point addition
            l = (other.y - self.y) * self._inv(other.x - self.x, p) % p
        x3 = (l * l - self.x - other.x) % p
        y3 = (l * (self.x - x3) - self.y) % p
        return Point(self.curve, x3, y3)

    def __rmul__(self, k):
        k = BigInt(k)
        result = Point(self.curve)
        addend = self
        while k > 0:
            if k % 2 == 1:
                result = result + addend
            addend = addend + addend
            k //= 2
        return result

    def _inv(self, x, p):
        # Extended Euclidean Algorithm for modular inverse
        x = x % p
        if x == 0:
            raise ZeroDivisionError('No inverse exists')
        lm, hm = BigInt(1), BigInt(0)
        low, high = x, p
        while low > 1:
            r = high // low
            nm, new = hm - lm * r, high - low * r
            hm, high, lm, low = lm, low, nm, new
        return lm % p
