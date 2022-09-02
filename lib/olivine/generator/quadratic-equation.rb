module Olivine::Generator::QuadraticEquation

  class Base < Olivine::Generator::Base
    set_unit '二次方程式', 370
    protected

    def format_quiz(expr)
      "二次方程式$#{format_expression(expr)}$を解け。"
    end

    def format_answer(expr)
      "$x=#{format_expression(expr)}$"
    end
  end
end

require_dir "quadratic-equation"
