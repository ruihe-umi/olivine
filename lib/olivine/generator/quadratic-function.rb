module Olivine::Generator::QuadraticFunction
  class Base < Olivine::Generator::Base
    set_unit '二次関数', 420
    protected

    def format_quiz(expr)
      expr
    end

    def format_answer(expr)
      expr
    end
  end
end

require_dir "quadratic-function"
