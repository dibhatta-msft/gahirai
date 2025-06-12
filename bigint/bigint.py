"""
BigInt: Infinite precision integer class for cryptographic and general use.
Efficient, modular, and extensible.
"""

class BigInt:
    BASE = 10 ** 9  # Each element in digits stores up to 9 decimal digits
    BASE_DIGITS = 9

    def __init__(self, value=0):
        if isinstance(value, BigInt):
            self.digits = value.digits[:]
            self.sign = value.sign
        elif isinstance(value, int):
            self.sign = 1 if value >= 0 else -1
            value = abs(value)
            self.digits = []
            if value == 0:
                self.digits.append(0)
            while value > 0:
                self.digits.append(value % self.BASE)
                value //= self.BASE
        elif isinstance(value, str):
            self._from_string(value)
        else:
            raise TypeError("Unsupported type for BigInt initialization.")
        self._normalize()

    def _from_string(self, s):
        s = s.strip()
        self.sign = 1
        if s[0] == '-':
            self.sign = -1
            s = s[1:]
        elif s[0] == '+':
            s = s[1:]
        self.digits = []
        for i in range(len(s), 0, -self.BASE_DIGITS):
            start = max(0, i - self.BASE_DIGITS)
            self.digits.append(int(s[start:i]))
        self._normalize()

    def _normalize(self):
        while len(self.digits) > 1 and self.digits[-1] == 0:
            self.digits.pop()
        if len(self.digits) == 1 and self.digits[0] == 0:
            self.sign = 1

    def __str__(self):
        s = ''.join(str(d).zfill(self.BASE_DIGITS) for d in reversed(self.digits))
        s = s.lstrip('0') or '0'
        return ('-' if self.sign < 0 else '') + s

    def __repr__(self):
        return f"BigInt('{str(self)})'"

    def __eq__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        return self.sign == other.sign and self.digits == other.digits

    def __lt__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        if self.sign != other.sign:
            return self.sign < other.sign
        if len(self.digits) != len(other.digits):
            return (len(self.digits) < len(other.digits)) if self.sign > 0 else (len(self.digits) > len(other.digits))
        for a, b in zip(reversed(self.digits), reversed(other.digits)):
            if a != b:
                return (a < b) if self.sign > 0 else (a > b)
        return False

    def __le__(self, other):
        return self < other or self == other

    def __gt__(self, other):
        return not (self <= other)

    def __ge__(self, other):
        return not (self < other)

    def __add__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        if self.sign == other.sign:
            result = BigInt()
            result.sign = self.sign
            result.digits = self._add_digits(self.digits, other.digits)
            result._normalize()
            return result
        else:
            if self.sign < 0:
                return other - (-self)
            else:
                return self - (-other)

    def __neg__(self):
        result = BigInt(self)
        if result != 0:
            result.sign *= -1
        return result

    def __sub__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        if self.sign == other.sign:
            if abs(self) >= abs(other):
                result = BigInt()
                result.sign = self.sign
                result.digits = self._sub_digits(self.digits, other.digits)
                result._normalize()
                return result
            else:
                result = BigInt()
                result.sign = -self.sign
                result.digits = self._sub_digits(other.digits, self.digits)
                result._normalize()
                return result
        else:
            return self + (-other)

    def __abs__(self):
        result = BigInt(self)
        result.sign = 1
        return result

    def _add_digits(self, a, b):
        res = []
        carry = 0
        for i in range(max(len(a), len(b))):
            x = a[i] if i < len(a) else 0
            y = b[i] if i < len(b) else 0
            s = x + y + carry
            res.append(s % self.BASE)
            carry = s // self.BASE
        if carry:
            res.append(carry)
        return res

    def _sub_digits(self, a, b):
        res = []
        carry = 0
        for i in range(len(a)):
            x = a[i]
            y = b[i] if i < len(b) else 0
            s = x - y - carry
            if s < 0:
                s += self.BASE
                carry = 1
            else:
                carry = 0
            res.append(s)
        # No need to handle negative result here
        return res

    def __mul__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        result = BigInt()
        result.sign = self.sign * other.sign
        result.digits = [0] * (len(self.digits) + len(other.digits))
        for i in range(len(self.digits)):
            carry = 0
            for j in range(len(other.digits)):
                s = result.digits[i + j] + self.digits[i] * other.digits[j] + carry
                result.digits[i + j] = s % self.BASE
                carry = s // self.BASE
            result.digits[i + len(other.digits)] += carry
        result._normalize()
        return result

    def __rmul__(self, other):
        return self.__mul__(other)

    def __floordiv__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        if other == 0:
            raise ZeroDivisionError("BigInt division by zero")
        if abs(self) < abs(other):
            return BigInt(0)
        quotient, _ = self._divmod(other)
        return quotient

    def __mod__(self, other):
        if not isinstance(other, BigInt):
            other = BigInt(other)
        if other == 0:
            raise ZeroDivisionError("BigInt modulo by zero")
        _, remainder = self._divmod(other)
        # Always return a non-negative remainder
        if remainder.sign < 0:
            remainder += abs(other)
        return remainder

    def _divmod(self, other):
        try:
            # Long division algorithm
            a = abs(self)
            b = abs(other)
            n = len(a.digits)
            m = len(b.digits)
            if m == 1:
                # Fast path for single-digit divisor
                q_digits = []
                r = 0
                for i in range(n - 1, -1, -1):
                    cur = a.digits[i] + r * self.BASE
                    q_digits.append(cur // b.digits[0])
                    r = cur % b.digits[0]
                q_digits.reverse()
                quotient = BigInt()
                quotient.sign = self.sign * other.sign
                quotient.digits = q_digits
                quotient._normalize()
                remainder = BigInt(r)
                remainder.sign = self.sign
                remainder._normalize()
                return quotient, remainder
            # General case fallback for large numbers
            a_int = int(str(a))
            b_int = int(str(b))
            q_int, r_int = divmod(a_int, b_int)
            quotient = BigInt(q_int)
            quotient.sign = self.sign * other.sign
            remainder = BigInt(r_int)
            remainder.sign = self.sign
            return quotient, remainder
        except Exception as e:
            # Fallback: use Python's int for all digits
            a_int = int(str(self))
            b_int = int(str(other))
            q_int, r_int = divmod(a_int, b_int)
            quotient = BigInt(q_int)
            quotient.sign = self.sign * other.sign
            remainder = BigInt(r_int)
            remainder.sign = self.sign
            return quotient, remainder

    def __truediv__(self, other):
        return self.__floordiv__(other)
