require 'bigdecimal/util'

module Olivine::Generator::Probability
  class Histogram < Frequency
    set_code 220
    set_label 'ヒストグラム'

    def initialize
      @figure_method = :to_histogram
      @figure_name = "ヒストグラム"
    end
  end
end
