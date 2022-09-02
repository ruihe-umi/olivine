module Olivine::Generator::QuadraticEquation
  class Factorisation < Base
    set_code 100
    set_label '因数分解・平方根'



    def expression
      (-9..9).to_a.combination(2) do |p, q|
        co = [1, -(p + q), p * q]
        expr = co
               .zip(['x^2', 'x', ''])
               .map do |c, v|
                 c.zero? ? nil : c.to_s + v
               end
               .compact
               .join('+') + '=0'
        ans = p == -q ? "\\pm{#{q}}" : "#{p}, #{q}"

        yield expr, ans

        unless co[1].zero?
          if co[1].even?
            n = co[1] / 2
            m = n**2 - co[2]

            yield "(x+#{n})^2=#{m}", ans if m.nonzero?
          else
            yield "#{co[0]}x^2+#{co[1]}x=#{-co[2]}", ans unless co[2].zero?
          end
        end

      end
    end
  end
end
