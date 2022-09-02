module Olivine::Generator::QuadraticEquation
  class Formula < Base
    set_code 200
    set_label '平方完成・解の公式'

    

    def expression
      digit = (-9..9).to_a
      (1..9).each do |a|
        digit.repeated_permutation(2) do |b, c|
          d = b**2 - 4 * a * c
          r = d.positive? ? Sqrt[1, d].simplified : nil
          next if r.nil? || r.zahlen? || r.r > 100

          expr = "#{a}x^2"
          expr += "+#{b}x" unless b.zero?
          expr += "+#{c}" unless c.zero?
          expr += "=0"

          den = 2 * a
          gcd = r.c.gcd(b).gcd(den)
          if gcd > 1
            den /= gcd
            b /= gcd
            r.c /= gcd
          end
          if b.zero?
            if den == 1
              ans = "\\pm#{r}"
            elsif r.c == 1
              ans = "\\pm\\dfrac{#{r}}{#{den}}"
            else
              ans = "\\pm\\dfrac{#{r.c}}{#{den}}\\sqrt{#{r.r}}"
            end
          else
            num = "#{-b}\\pm#{r}"
            if den == 1
              ans = num
            else
              ans = "\\dfrac{#{num}}{#{den}}"
            end
          end

          yield expr, ans
        end
      end
    end
  end
end
