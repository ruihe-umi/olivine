module Olivine::Generator::QuadraticFunction
  class Proportion < Base
    set_code 110
    set_label '変化の割合'

    

    def expression
      proportion do |a|
        fun = format('y=%sx^2', a.to_tex).sub(/1(?=x)/, '')
        DIGIT.combination(2) do |n, m|
          ans = (a * m**2 - a * n**2).quo(m - n)
          next unless ans.numerator.abs < 100

          str1 = format('$x$の値が$%d$から$%d$まで変化するときの変化の割合', n, m)
          quiz = format('関数$%s$について，%sを求めよ。', fun, str1)

          yield quiz, "$#{ans.to_tex}$"
        end
      end
    end

    def proportion
      DIGIT.each do |n|
        yield n
        (1...n.abs).each do |m|
          yield m.quo(n) if m.prime_to?(n)
        end
      end
    end
  end
end
