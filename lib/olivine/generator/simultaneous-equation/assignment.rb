module Olivine::Generator::SimultaneousEquation
  class Assignment < Base
    set_code 200
    set_label '代入法'

    def expression
      coefficient do |x1, y1|
        DIGIT.each do |x2|
          next if -x1 == x2 * y1
          answer do |x, y|
            c1 = x1 * x + y1 * y
            c2 = y - x2 * x
            next if c1 == c2 || c2.zero? || c1.abs > 9 || c2.abs > 9

            exp = [
              "#{x1}x+#{y1}y=#{c1}",
              "y=#{x2}x+#{c2}"
            ]

            yield exp, [x, y]
          end
        end
      end
    end

    def answer(&block)
      (-9..9).to_a
             .repeated_permutation(2, &block)
    end

    def coefficient(&block)
      DIGIT.repeated_permutation(2, &block)
    end
  end
end
