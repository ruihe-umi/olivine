module Olivine::Generator::Polynominal
  class ExpansionAddition < Expansion
    set_code 200
    set_label '多項式の展開'

    

    def expression
      @var = [['x'], ['x', 'y'], ['a']]
      coefficient do |e, a|
        @var.each do |x, y|
          formula = form(e, x, y)
          DIGIT.each do |c|
            ln = a[1] + c
            answer = "#{a[0]}#{x}^2"
            answer += "+#{ln}#{x}#{y}" unless ln.zero?
            answer += "+#{a[2]}"
            answer += "#{y}^2" if y

            term = "#{c}#{x}#{y}"
            yield "#{formula}+#{term}", answer
            yield "#{term}+#{formula}", answer if c.positive?

            unless y
              [-1, 1].each do |p|
                sq = a[0] + p
                ln = a[1] + p * c
                answer = []
                answer << "#{sq}#{x}^2" unless sq.zero?
                answer << "#{ln}#{x}" unless ln.zero?
                answer << "#{a[2]}"
                ans = answer * '+'

                term = "#{p}#{x}(#{x}+#{c})"
                yield "#{formula}+#{term}", ans
                yield "#{term}+#{formula}", ans
              end
            end
          end
        end
      end
    end

  end
end
