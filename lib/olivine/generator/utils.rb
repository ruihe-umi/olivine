module Olivine::Generator
  module Utils
    # *よい感じ*の分数を渡す
    # ----------
    # よい感じというのは、既約真分数であって、
    # しかも分母があまり大きすぎる素因数をもたないことである。
    def frac(max_denominator = 20, max_prime_factor = 13, only_proper: true)
      return to_enum(:frac) unless block_given?

      2.upto(max_denominator).each do |denominator|
        next if Prime.prime_division(denominator).any? { |p, _e| p > max_prime_factor }

        max_numerator = only_proper ? denominator : max_denominator
        (-max_numerator).upto(max_numerator) do |numerator|
          next unless numerator.nonzero? && numerator.gcd(denominator) == 1

          yield Rational(numerator, denominator)
        end
      end
    end

    # yields non-zero digit from min to max
    def nonzero_digit(min: -9, max: 9)
      raise ArgumentError, 'min is greater than max' if min > max

      (min..max).filter { |i| i.nonzero? }
    end

    def well_behaved_angle(min: 30, max: 180)
      return to_enum(:well_behaved_angle, min: min, max: max) unless block_given?

      1.upto(18) do |den|
        next if 360.modulo(den).nonzero?
        num = 1
        until (a = 360 / den * num) > max
          yield a if num.prime_to?(den) && a >= min
          num += 1
        end
      end
    end

    def phi(x, mu: 0, var: 1)
      Math.erfc((mu - x) / Math.sqrt(2 * var)) / 2
    end

    # 平方根を表す構造体
    # __c__: 係数
    # __r__: 被開方数
    Sqrt = Struct.new(:c, :r) do
      def simplified
        d = r.prime_division
        p = c * d.inject(1) { |acc, (p, e)| acc * p**(e / 2) }
        q = d.inject(1) { |acc, (p, e)| acc * p**(e % 2) }
        Sqrt[p, q]
      end

      def zero?
        c.zero? || r.zero?
      end

      def zahlen?
        zero? || r == 1
      end

      def to_s
        s = simplified
        return nil if s.zero?
        return s.c.to_s if s.r == 1

        "#{s.c}\\sqrt{#{s.r}}"
      end

      def +(other)
        left = simplified
        right = other.simplified
        raise ArgumentError, 'Radicands are different' unless left.r == right.r

        Sqrt[(left.c + right.c)**2 * left.r]
      end

      def -(other)
        left = simplified
        right = other.simplified
        raise ArgumentError, 'Radicands are different' unless left.r == right.r

        Sqrt[(left.c - right.c)**2 * left.r]
      end
    end
  end
end
