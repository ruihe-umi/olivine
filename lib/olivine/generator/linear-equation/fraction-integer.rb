module Olivine::Generator::LinearEquation
  # 分数係数型
  class FractionInteger < Base
    set_code 210
    set_label '分数左辺'
    set_note '分数＋分数＝定数'

    

    MAX_INT = 9
    MAX_ANSWER = 12

    def expression
      denominator do |a, d|
        numerator do |b, c|
          next if b.negative?

          left = fraction(a, b, c)
          next if left.nil?
          numerator do |e, f|
            right = fraction(d, e, f)
            next if right.nil?
            DIGIT.each do |ans|
              lnum = d * (b * ans + c)
              rnum = a * (e * ans + f)
              const = (lnum + rnum).quo(a * d)
              yield "#{left}+#{right}=#{const.truncate}", ans if const.zahlen? && const.abs < 10
            end
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

    def numerator(&block)
      nonzero_digit(min: -MAX_INT, max: MAX_INT)
        .permutation(2, &block)
    end

    def denominator(&block)
      (2..9).to_a.permutation(2, &block)
    end
  end
end
