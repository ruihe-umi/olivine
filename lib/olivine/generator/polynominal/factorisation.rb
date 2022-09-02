module Olivine::Generator::Polynominal
  class Factorisation < Expansion
    set_code 110
    set_label '因数分解'

    protected

    def format_quiz(expr)
      "$#{format_expression(expr)}$を因数分解せよ。"
    end

    

    def expression
      expressions = []
      super do |a, e|
        unless expressions.include?(e)
          yield e, a
          expressions.push e
        end
      end
    end
  end
end
