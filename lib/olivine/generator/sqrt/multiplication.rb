module Olivine::Generator::SquareRoot
  class Multiplication < Base
    set_code 110
    set_label '乗除算'



    def expression
      factors do |a, b, c, ans|
        yield "#{a}*#{b}/#{c}", ans
        yield "#{a}/#{c}*#{b}", ans
      end
    end

    def root(int)
      d = int.prime_division
      co = d.inject(1) { |acc, (p, e)| acc * p**(e / 2) }
      r = d.inject(1) { |acc, (p, e)| acc * p**(e % 2) }
      return ["#{co}"] if r == 1

      ary = ["#{co}\\sqrt{#{r}}"]
      unless co == 1
        co.negative? && sign = '-'
        r.prime? && (num = co * r) < 99 && ary << "#{sign}\\dfrac{#{num}}{\\sqrt{#{r}}}"
        (a = co**2 * r) < 109 && ary << "#{sign}\\sqrt{#{a}}"
      end
      ary
    end

    def factors
      answer do |p, q|
        ans = "#{p}\\sqrt{#{q}}"
        WELL_DEFINED_INT.each do |c|
          d = p**2 * q * c
          d.divisor.each do |r|
            next if r == 1 || r == d

            a = root(r)
            b = root(d / r)

            a.product(b) do |ax, bx|
              yield ax, bx, "\\sqrt{#{c}}", ans
            end
          end
        end
      end
    end

    def answer
      (2..9).each do |p|
        RADICAND.each do |q|
          yield p, q
        end
      end
    end
  end
end
