module Olivine::Generator::Polynominal
  class FactorisationReplacement < Factorisation
    set_code 220
    set_label '因数分解(置換)'

    

    def expression
      @var = ['x', 'a']
      coefficient do |p, q|
        ln = p + q
        co = p * q
        next if ln.abs > 9
        @var.each do |x|
          DIGIT.each do |c|
            term = "#{x}+#{c}"
            expr = ["(#{term})^2"]
            expr << "#{ln}(#{term})" unless ln.zero?
            expr << co.to_s
            ls, gt = [c+p, c+q].minmax
            if ls.zero?
              ans = "#{x}(#{x}+#{gt})"
            elsif gt.zero?
              ans = "#{x}(#{x}+#{ls})"
            else
              ans = "(#{x}+#{gt})(#{x}+#{ls})"
            end

            yield expr.join('+'), ans
          end
        end
      end
    end

    def coefficient(&block)
      DIGIT.combination(2, &block)
    end
  end
end
