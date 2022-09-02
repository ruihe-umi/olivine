module Olivine::Generator::SquareRoot

  class Base < Olivine::Generator::Base
    set_unit '平方根', 360

    RADICAND = [2, 3, 5, 6, 7]
    WELL_DEFINED_INT = [2, 3, 5, 6, 7, 8, 12, 15, 18, 20]
    POSITIVE_DIGIT = DIGIT.select { |e| e.positive? }
  end
end

class Integer
  def divisor
    prime_division.inject([1]) do |ary, (p, e)|
      (0..e).map{ |e1| p ** e1 }.product(ary).map{ |a, b| a * b }
    end.sort
  end
end

require_dir 'sqrt'
