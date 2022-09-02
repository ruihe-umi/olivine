module Olivine::Generator::SimultaneousEquation
  class Elimination < Base
    set_code 100
    set_label '消去法'

    

    def expression
      coefficient.combination(2) do |co|
        x1, y1 = co[0]
        x2, y2 = co[1]
        next if x1 * y2 == x2 * y1
        answer do |x, y|
          c1 = x1 * x + y1 * y
          c2 = x2 * x + y2 * y
          next if c1 == c2 || c1.abs > 9 || c2.abs > 9

          exp = [
            "#{x1}x+#{y1}y=#{c1}",
            "#{x2}x+#{y2}y=#{c2}"
          ]

          yield exp, [x, y]
        end
      end
    end

    def answer(&block)
      (-9..9).to_a
             .repeated_permutation(2, &block)
    end

    def coefficient
      DIGIT.repeated_permutation(2).to_a
    end
  end
end
