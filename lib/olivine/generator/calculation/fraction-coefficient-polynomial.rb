module Olivine::Generator::Calculation
  # 分数係数の文字式の計算を出力する
  # (bx+cy)/a+(ex+fy)/d型
  class FractionCoefficientPolynomial < Base
    set_label '分数係数'
    set_code 110

    

    MAX_INT = 9

    def expression
      denominator do |a, d|
        numerator do |b, c|
          next if b.negative?
          lhs = fraction(a, b, c)
          numerator do |e, f|
            rhs = fraction(d, e, f)
            expr = "#{lhs}+#{rhs}"

            lcm = a.lcm(d)
            p = lcm / a
            q = lcm / d
            co_x = p * b + q * e
            co_y = p * c + q * f
            answer = fraction(lcm, co_x, co_y)

            yield expr, answer if lcm < 20 && co_x.abs < 20 && co_y.abs < 20 && co_x != co_y
          end
        end
      end
    end

    def fraction(den, lnum, rnum)
      if lnum.negative? ||
         lnum.zero? && rnum.negative?
        lnum = -lnum
        rnum = -rnum
        sign = '-'
      end

      gcd = lnum.gcd(rnum).gcd(den)
      if gcd > 1
        lnum /= gcd
        rnum /= gcd
        den /= gcd
      end

      num = []
      num << "#{lnum}x" if lnum.nonzero?
      num << "#{rnum}y" if rnum.nonzero?
      return '0' if num.empty?
      if num.size > 1
        "#{sign}\\dfrac{#{num.join('+')}}{#{den}}"
      else
        var = num[0].slice!(-1)
        "#{sign}\\dfrac{#{num[0]}}{#{den}}#{var}"
      end
    end

    # 分子(b,c)と(e,f)はそれぞれ互いに素である
    def numerator
      (-MAX_INT..MAX_INT)
        .reject { |e| e.zero? }
        .permutation(2)
        .each do |l, r|
          yield l, r if l.prime_to?(r)
        end
    end

    # 分母a,dは正数である
    def denominator(&block)
      [2,3,4,5,6,8].permutation(2, &block)
    end
  end
end
