module Olivine::Generator::SquareRoot
  class BasicCalculation < Base
    set_code 120
    set_label '四則混合'


    def expression
      addition do |a, prod, ans|
        yield "#{a}+#{prod}", ans
        yield "#{prod}+#{a}", ans
      end
    end

    def root(int, negative = false)
      negative && sign = '-'
      d = int.prime_division
      co = d.inject(1) { |acc, (p, e)| acc * p**(e / 2) }
      r = d.inject(1) { |acc, (p, e)| acc * p**(e % 2) }
      return ["#{sign}#{co}"] if r == 1

      ary = ["#{sign}#{co}\\sqrt{#{r}}"]
      unless co == 1
        r.prime? && (num = co * r) < 99 && ary << "#{sign}\\dfrac{#{num}}{\\sqrt{#{r}}}"
        (a = co**2 * r) < 109 && ary << "#{sign}\\sqrt{#{a}}"
      end
      ary
    end

    def addition
      RADICAND.each do |r|
        DIGIT
          .product(POSITIVE_DIGIT)
          .each do |a, b|
          add = "#{a}\\sqrt{#{r}}"
          ans = (co = a + b).zero? ? '0' : "#{co}\\sqrt{#{r}}"
          multiplication(b, r) do |prod|
            yield add, prod, ans
          end
          division(b, r) do |prod|
            yield add, prod, ans
          end
        end
      end
    end

    def multiplication(co, ra)
      d = co**2 * ra
      d.divisor.each do |p|
        next if p == 1 || p == d

        q = d / p
        next if Integer.sqrt(p)**2 == p || Integer.sqrt(q)**2 == q

        root(p)
          .product(root(q)) do |l, r|
          yield "#{l}*#{r}"
        end
      end
    end

    def division(co, ra)
      WELL_DEFINED_INT.each do |c|
        p = co**2 * ra * c
        root(p).each do |a|
          yield "#{a}/\\sqrt{#{c}}"
        end
      end
    end
  end
end
