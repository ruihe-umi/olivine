module Olivine::Generator::Calculation
  # 整数係数の文字式の計算を出力する
  # ----------
  # a(bx+cy)+d(ex+fy)型
  class IntegerCoefficientPolynomial < Base
    set_label '整数係数'
    set_code 100

    

    MAX_DIGIT = 7

    # 解の係数は10未満でなければならない
    def expression
      coefficient do |a, b, c, d, e, f|
        answer_x = a * b - d * e
        answer_y = a * c - d * f
        next unless answer_x.abs < 10 && answer_y.abs < 10

        lhs = "#{b}x+#{c}y"
        lhs = "#{a}(#{lhs})" unless a == 1
        rhs = "#{d}(#{e}x+#{f}y)"
        expr = "#{lhs}=#{rhs}"
        answer = []
        answer_x.nonzero? && answer << "#{answer_x}x"
        answer_y.nonzero? && answer << "#{answer_y}y"
        answer.empty? && answer << '0'

        yield expr, answer.join('+')
      end
    end

    # (b,e)(c,f)は互いに素でなければならない
    def coefficient
      outer do |a, d|
        inner do |b, c|
          inner do |e, f|
            yield a, b, c, d, e, f if b.prime_to?(e) && c.prime_to?(f)
          end
        end
      end
    end

    # (b,c)(e,f)は互いに素でなければならない
    def inner
      positive_digit
        .product(digit)
        .each do |left, right|
          yield left, right if left.prime_to?(right)
        end
    end

    # a, d は互いに素であり、かつdは1以外でなければならない
    def outer
      digit
        .permutation(2)
        .each do |left, right|
          yield left, right if left.prime_to?(right) && right != 1
        end
    end

    def positive_digit
      (1..MAX_DIGIT).to_a
    end

    def digit
      nonzero_digit(min: -MAX_DIGIT, max: MAX_DIGIT)
    end
  end
end
