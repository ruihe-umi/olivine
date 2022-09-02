module Olivine::Generator::Polynominal
  class Expansion < Base
    set_code 100
    set_label '乗法公式'

    def initialize
      @var = [['x', nil], ['x', 'y'], ['a', 'b']]
    end
    

    def expression
      coefficient do |quiz, a|
        @var.each do |x, y|
          exp = form(quiz, x, y)

          answer = "#{a[0]}#{x}^2"
          answer += "+#{a[1]}#{x}#{y}" unless a[1].zero?
          answer += "+#{a[2]}"
          answer += "#{y}^2" if y
          yield exp, answer
          if quiz[2] && quiz[1].negative?
            yield form([-quiz[1], -quiz[0], 2], y, x), answer
          end
        end
      end
    end

    def form(co, x, y = nil)
      if co[2]
        "(#{co[0]}#{x}+#{co[1]}#{y})^#{co[2]}"
      else
        "(#{x}+#{co[0]}#{y})(#{x}+#{co[1]}#{y})"
      end
    end

    def coefficient
      DIGIT.repeated_permutation(2) do |l, r|
        if l == r
          (1..9).each do |a|
            yield [a, l, 2], [a ** 2, 2 * a * l, l ** 2] unless a == l
          end
        else
          yield [l, r], [1, l + r, l * r]
        end
      end
    end
  end
end
