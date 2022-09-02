module Olivine::Generator::LinearEquation
  class Base < Olivine::Generator::Base
    set_unit '一次方程式', 330
    protected

    def format_quiz(expr)
      "一次方程式$#{format_expression(expr)}$を解け。"
    end

    def format_answer(expr)
      "$x=#{format_expression(expr)}$"
    end
  end
end

require_dir "linear-equation"
