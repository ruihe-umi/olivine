module Olivine::Generator::SignedNumber
  # 正負の数　四則混合
  # 整数のみのもの
  class Integer < Base
    set_label '四則混合(整数)'
    set_code 100

    

    def expression
      products do |p, v|
        DIGIT.each do |i|
          a = v + i
          yield "#{p}+#{i}", a
          yield "#{i}+#{p}", a
        end
      end
    end

    def products
      DIGIT
      .reject { |e| e.abs < 2 }
      .repeated_permutation(2).each do |a, b|
        yield "#{a}*#{b}", a * b unless [a, b].all? { |e| e > 6 }
        yield "#{a * b}/#{b}", a unless b > 6
      end
    end
  end
end
