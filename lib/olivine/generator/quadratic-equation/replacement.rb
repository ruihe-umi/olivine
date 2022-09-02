module Olivine::Generator::QuadraticEquation
  class Replacement < Base
    set_code 300
    set_label '乗法公式の利用'

    

    def expression
      answer.each do |p, q|
        ans = p == -q ? "\\pm#{q}" : "#{p}, #{q}"

        formulae(p, q) do |e|
          yield e, ans
        end

        replacement(p, q) do |e, a|
          yield e, a
        end
      end
    end

    # 置き換えるパターン。
    # A^2+bA+c=0(A=mx+n)の形。
    def replacement(p, q)
      (1..9).each do |m|
        DIGIT.each do |n|
          next unless m.prime_to?(n)
          p1 = (p - n).quo(m)
          q1 = (q - n).quo(m)
          ans = p1 == -q1 ? "\\pm#{q1.to_tex}" : "#{p1.to_tex},#{q1.to_tex}"

          t = "(#{m}x+#{n})"
          co1 = p + q
          co2 = p * q
          if co1.zero?
            yield "#{t}^2+#{co2}=0", ans
          else
            yield "#{t}^2+#{-co1}#{t}+#{co2}=0", ans
            yield "#{t}^2+#{co1}(#{-n}+#{-m}x)+#{co2}=0", ans if n.negative?
          end
        end
      end
    end

    # 乗法公式を利用して展開・整理するパターン。
    # (x+a)(x+b)=mx+n の形。
    def formulae(p, q)
      DIGIT.permutation(2) do |a, b|
        lhs = "(x+#{a})(x+#{b})"
        co1 = a + b + p + q
        co2 = a * b - p * q

        next if co1.zero? && co2.zero?
        next if co1.prime_to?(co2) && (co1.abs > 9 || co2.abs > 9)
        next if co1.abs > (gcd = co1.gcd(co2)) * 10 || co2.abs > gcd * 20
        next if co1.nonzero? && (
          a == (f = co2.quo(co1)) ||
          b == f)

          yield "#{lhs}=#{linear(co1, co2)}"
          yield "#{lhs}+#{linear(-co1, -co2)}=0"
        end
    end

    def linear(co1, co2)
      if co1.zero?
        co2.to_s
      elsif co2.zero?
        "#{co1}x"
      else
        gcd = co1.gcd(co2)
        co1 /= gcd
        co2 /= gcd

        rhs = if co1.positive?
                "#{co1}x+#{co2}"
              elsif co2.positive?
                "#{co2}+#{co1}x"
              elsif gcd == 1
                "#{co1}x+#{co2}"
              else
                gcd = -gcd
                "#{-co1}x+#{-co2}"
              end

        gcd == 1 ? rhs : "#{gcd}(#{rhs})"
      end
    end

    def answer
      DIGIT.combination(2)
    end
  end
end
