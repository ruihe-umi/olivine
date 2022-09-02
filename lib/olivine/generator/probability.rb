module Olivine::Generator::Probability
  class Base < Olivine::Generator::Base
    PathFinder = Olivine::PathFinder

    set_unit 'データの活用', 610

    def format_quiz(expr)
      expr
    end
  end

end

require_relative 'probability/number_of_cases.rb'
require_relative 'probability/probability.rb'
require_relative 'probability/sampling.rb'
require_relative 'probability/frequency.rb'
require_relative 'probability/histogram.rb'
