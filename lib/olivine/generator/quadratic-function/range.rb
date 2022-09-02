module Olivine::Generator::QuadraticFunction
  class Range < Base
    set_code 100
    set_label '変域'

    

    def expression
      proportion do |a|
        fun = format('y=%sx^2', a.to_tex).sub(/1(?=x)/, '')
        DIGIT.combination(2) do |n, m|
          y_range = [a * n**2, a * m**2]
          next unless y_range.all? { |e| e.zahlen? && e.abs < 100 }
          y_range << 0 if n * m < 0
          min, max = y_range.minmax

          ['\\leqq', '<'].repeated_permutation(2) do |l, r|
            x_range = format('%d%s x%s%d', n, l, r, m)
            str1 = format('$x$の変域が$%s$のときの$y$の変域', x_range)
            quiz = format('関数$%s$について，%sを求めよ。', fun, str1)
            ans = format('$%s%s y%s%s$',
              min.to_tex,
              min.zero? ? '\\leqq' : min == y_range.first ? l : r,
              max.zero? ? '\\leqq' : max == y_range.first ? l : r,
              max.to_tex)

            yield quiz, ans
          end
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
