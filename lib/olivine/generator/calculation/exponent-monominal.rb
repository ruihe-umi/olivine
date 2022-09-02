module Olivine::Generator::Calculation
  # x^ay^b が３つあって乗除算でつながっている型
  # ------------------
  # 3乗も入れたかったけれど、44万中32万件が3乗がらみになってしまうのは
  # 偏りがひどいので除いた
  class ExponentMonominal < Base
    set_code 120
    set_label '指数法則'

    

    EXPONENT = [0, 1, 2]

    def expression
      factors do |mul1, mul2, div, ans|
        mul2[0] == '-' && mul2 = "(#{mul2})"
        div[0] == '-' && div = "(#{div})"
        yield "#{mul1}/ #{div}* #{mul2}", ans
        yield "#{mul1}* #{mul2}/ #{div}", ans
      end
    end

    def form_exponent(char, ex)
      return '' if ex.zero?
      return char if ex == 1
      return "#{char}^#{ex}"
    end

    def factors
      products do |prod|
        yield(
          prod.map do |co, exp|
          if exp == [2, 2]
            exp = [1, 1]
            gcd = 2
          end
          str = co.to_tex
          str += form_exponent('x', exp[0])
          str += form_exponent('y', exp[1])
          if gcd.nil?
            str
          else
            "(#{str})^#{gcd}"
          end
        end
      )
      end
    end

    def products
      pairs do |exp|
        coefficients do |co|
          ary = co.zip(exp)
          has_gcd = ary.filter { |e| e[1] == [2, 2] }
          if has_gcd.empty?
            yield ary
          elsif has_gcd.all? { |e| [1, 4].include?(e[0]) }
            has_gcd.map { |e| e[0] = Integer.sqrt(e[0]) }
            yield ary
            has_gcd.map { |e| e[0] = -e[0] }
            yield ary
          end
        end
      end
    end

    def coefficients
      nonzero_digit(min: -6, max: 6).permutation(3) do |co|
        ans = (co[0] * co[1]).quo(co[2])
        yield co + [ans.truncate] if ans.zahlen?
      end
    end

    def pairs
      exponents do |x|
        exponents do |y|
          res = [x, y].transpose
          unless res.any? { |e| e.all?(0) || e.all?(3) } ||
                 res.all? { |e| e.sum == 1 } ||
                 res[0] == res[1] ||
                 res[3].all?(2)
            yield res
          end
        end
      end
    end

    def exponents
      EXPONENT.repeated_permutation(2) do |exp|
        next if exp.all?(0) || exp.all?(3)

        exp.uniq.each do |e|
          res = exp.sum - e
          yield exp + [e, res]
        end
      end
    end
  end
end
