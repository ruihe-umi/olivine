module Olivine::Generator::SquareRoot
  class ExpansionFormula < Base
    set_code 130
    set_label '乗法公式の利用'



    Answer = Struct.new(:int, :root) do
      def method_missing(op)
        [int.inject(op), root.inject(op)]
      end
    end

    def expression
      formula do |str, co|
        yield str, answer(*co)
        next if co[1].zero?
        sqrt = co[1].simplified
        if co[0].abs < 10 && sqrt.r < 20 && sqrt.c.abs < 10
          DIGIT.each do |d|
            ans = answer(co[0], Sqrt[sqrt.c + d, sqrt.r])
            add = "#{d}\\sqrt{#{sqrt.r}}"
            yield "#{str}+#{add}", ans
            yield "#{add}+#{str}", ans
          end
        end
      end
    end

    def answer(int, sqrt)
      ary = []
      ary << int unless int.zero?
      ary << sqrt.to_s unless sqrt.zero?
      ary.empty? ? "0" : ary.join('+')
    end

    def formula
      RADICAND.permutation(2) do |p, q|
        yield "(\\sqrt{#{p}}+\\sqrt{#{q}})^2", [p + q, Sqrt[2, p * q]]
        yield "(\\sqrt{#{p}}-\\sqrt{#{q}})^2", [p + q, Sqrt[-2, p * q]]
        yield "(\\sqrt{#{p}}+\\sqrt{#{q}})(\\sqrt{#{p}}-\\sqrt{#{q}})", [p - q, 0]
      end

      RADICAND.each do |r|
        DIGIT.repeated_permutation(2) do |p, q|
          ans = [r + p * q, Sqrt[p + q, r]]
          if p == q
            yield "(\\sqrt{#{r}}+#{p})^2", ans
          else
            yield "(\\sqrt{#{r}}+#{p})(\\sqrt{#{r}}+#{q})", ans
          end
        end
      end
    end

    def addition
      RADICAND do |r|
        POSITIVE_DIGIT.each do |a|
          add = "#{a}\\sqrt{#{r}}"
          formula(r) do |str, int, root|
            yield add, str, [[int], [root, Sqrt(a, r)]]
          end
        end
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
