class Numeric # :nodoc:
  def to_tex
    to_s
  end

  def to_odds
    "#{numerator}:#{denominator}"
  end

  def to_radian
    fdiv(180) * Math::PI
  end

  def to_degree
    self * 180 / Math::PI
  end

  def zahlen?
    denominator == 1
  end

  def digit
    16.times do |i|
      p = self * 10**i
      return i if p % 1 == 0
    end
  end
end

class BigDecimal # :nodoc:
  def to_tex
    to_s('f')
  end
end

class Integer # :nodoc:
  def divisors
    abs.prime_division.inject([1]) do |ary, (p, e)|
      (0..e).map { |e1| p**e1 }.product(ary).map { |a, b| a * b }
    end.sort
  end

  def prime_to?(other)
    raise "引数は整数でなければなりません: #{other}" unless other.is_a?(Integer)

    gcd(other) === 1
  end

  def square
    (r = Integer.sqrt(self))**2 == self ? r : nil
  end

  def square?
    r = Integer.sqrt(self)
    self == r**2
  end

  def multiple?(divisior)
    modulo(divisior).zero?
  end

  def permutation(n)
    raise RangeError if !n.is_a?(Integer) || n.negative? || negative? || n > self
    return 1 if n.zero? || zero?

    (self - n + 1..self).inject(:*)
  end

  def combination(n)
    raise RangeError if !n.is_a?(Integer) || n.negative? || negative? || n > self
    return 1 if n.zero? || zero?

    permutation(n) / (1..n).inject(:*)
  end
end

class Rational # :nodoc:
  def to_tex
    return numerator.to_s if zahlen?

    "#{negative? ? '-' : nil}\\dfrac{#{numerator.abs}}{#{denominator}}"
  end

  def proper?
    denominator > numerator
  end
end
