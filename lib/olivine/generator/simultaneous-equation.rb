module Olivine::Generator::SimultaneousEquation
  class Base < Olivine::Generator::Base
    set_unit '連立方程式', 340
    protected

    def format_quiz(expr)
      e1 = format_expression(expr[0])
      e2 = format_expression(expr[1])
      "連立方程式$\\left\\lbrace\\begin{array}{l}#{e1}\\cr #{e2}\\end{array}\\right.$を解け。"
    end

    def format_answer(ans)
      "$(x,y)=(#{ans[0]},#{ans[1]})$"
    end
  end
end

require_dir 'simultaneous-equation'
