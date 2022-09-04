module Olivine::Generator::LinearEquation
  # 分数係数型
  class Fraction < Base
    set_code 200
    set_label '分数両辺'
    set_note '分数＝分数'

    MAX_INT = 9
    MAX_ANSWER = 12

    def expression
      denominator do |a, d|
        numerator do |b, c|
          next if b.negative?

          lhs = fraction(a, b, c)
          next if lhs.nil?
          numerator do |e, f|
            rhs = fraction(d, e, f)
            next if rhs.nil?
            expr = "#{lhs}=#{rhs}"

            den = d * b - a * e
            num = a * f - d * c

            den.nonzero? && (ans = num.quo(den)).zahlen? && ans.abs <= MAX_ANSWER && yield(expr, ans)
          end
        end
      end
    end

    def fraction(den, lnum, rnum)
      if lnum.negative?
        lnum = -lnum
        rnum = -rnum
        sign = '-'
      end

      gcd = lnum.gcd(rnum).gcd(den)
      return nil if gcd > 1

      "#{sign}\\dfrac{#{lnum}x+#{rnum}}{#{den}}"
    end

    def numerator
      nonzero_digit(min: -MAX_INT, max: MAX_INT)
        .permutation(2)
        .each do |l, r|
          yield l, r unless l.negative? && r.negative?
        end
    end

    def denominator(&block)
      (2..9).to_a.permutation(2, &block)
    end
  end
end
