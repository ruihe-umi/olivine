module Olivine::Generator::Polynominal
  class Base < Olivine::Generator::Base
    set_unit '多項式', 350
  end
end

require_relative 'polynominal/expansion.rb'
require_relative 'polynominal/factorisation.rb'
require_relative 'polynominal/expansion-addition.rb'
require_relative 'polynominal/factorisation-replacement.rb'
