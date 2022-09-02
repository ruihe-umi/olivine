module Olivine::Generator::LinearEquation
  # ax+c=bx+d型
  # くくってa(x+p)のような形になってもよい
  class Integer < Base
    set_code 100
    set_label "整数係数"

    

    def expression
      coefficient do |lhs, rhs, ans|
        yield "#{lhs}=#{rhs}", ans
      end
    end

    def make_side(a, b, paren = false)
      if paren
        "#{a}(x+#{b})"
      else
        "#{a}x+#{b}"
      end
    end

    def coefficient(&block)
      DIGIT.permutation(2) do |a, c|
        den = a - c
        DIGIT.repeated_permutation(2) do |b, d|
          ans = (d - b).quo(den)
          lhs = make_side(a, b)
          rhs = make_side(c, d)
          yield lhs, rhs, ans if DIGIT.include?(ans)
          unless a.abs == 1 || c.abs == d.abs
            ans = (d - a * b).quo(den)
            lhs = make_side(a, b, true)
            rhs = make_side(c, d)
            if DIGIT.include?(ans)
              yield lhs, rhs, ans
              yield rhs, lhs, ans
            end
          end
          unless a.abs == 1 || c.abs == 1 || b == d
            ans = (c * d - a * b).quo(den)
            lhs = make_side(a, b, true)
            rhs = make_side(c, d, true)
            yield lhs, rhs, ans if DIGIT.include?(ans)
          end
        end
      end
    end
  end
end
