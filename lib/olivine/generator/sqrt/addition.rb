module Olivine::Generator::SquareRoot
  class Addition < Base
    set_code 100
    set_label "加減算"



    def expression
      terms do |l, r, a|
        l.product(r) do |exp|
          # except pairs who `look same`
          u = exp.uniq + exp.map { |e| '-' + e }
          yield exp.join('+'), a unless u.uniq.size < 4 || exp.all? { |e| e.include? "dfrac" }
        end
      end
    end

    def root(co, r)
      ary = ["#{co}\\sqrt{#{r}}"]
      unless co.abs == 1
        co.negative? && sign = '-'
        ary << "#{sign}\\dfrac{#{co.abs * r}}{\\sqrt{#{r}}}"
        (a = co ** 2 * r) < 109 && ary << "#{sign}\\sqrt{#{a}}"
      end
      return ary
    end

    def terms
      RADICAND.each do |r|
        DIGIT.repeated_permutation(2) do |c1, c2|
          next if (c1 * c2).abs == 1

          answer = (co = c1 + c2).zero? ? '0' : "#{co}\\sqrt{#{r}}"
          yield root(c1, r), root(c2, r), answer
        end
      end
    end
  end
end
