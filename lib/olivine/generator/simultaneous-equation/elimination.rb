module Olivine::Generator::SimultaneousEquation
  class Elimination < Base
    set_code 100
    set_label '消去法'

    def expression
      answer do |x, y|
        DIGIT
        .permutation(2) do |b1, b2|
          a1 = (y - b1).quo(x)
          a2 = (y - b2).quo(x)
          yield [equation(a1, b1), equation(a2, b2)], [x, y] unless a1 == a2 || [a1, a2].any?(&:zero?)
        end
      end
    end

    def equation(a, b)
      if a.positive?
        format('%dx+%dy=%d', a.numerator, -a.denominator, b * -a.denominator)
      else
        format('%dx+%dy=%d', -a.numerator, a.denominator, b * a.denominator)
      end
    end

    def answer(&block)
      DIGIT.repeated_permutation(2, &block)
    end

    def coefficient
      DIGIT.repeated_permutation(2).to_a
    end
  end
end
