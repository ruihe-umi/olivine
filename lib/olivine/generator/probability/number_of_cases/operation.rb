module Olivine::Generator::Probability
  class NumberOfCases
    def calculate(omega)
      CALCULATION.each do |str, p|
        test(s = omega.map(&p).count(true)) && yield(str, s)
      end
    end

    def compare
      COMPARISONS.each do |str, op|
        @whole.uniq.sort.each do |d|
          test(s = @whole.count { |v| v.send(op, d) }) && yield("#{d}#{str}", s)
        end
      end
    end

    def multiply
      MULTIPLES.each do |str, op, *arg|
        test(s = @whole.count { |v| v.send(op, *arg) }) && yield(str, s)
      end
    end

    def simple(omega)
      @whole = omega.map { |e| e[0] == e[1] }
      t = @whole.count(true)
      test(t) && yield("が同じ", t)
      f = @whole.count(false)
      test(f) && yield("が異なる数", f)
      [['和', :+], ['積', :*]]
        .product(%i[compare multiply])
        .each do |op, fun|
        @whole = omega.map { |e| e.inject(op[1]) }
        send(fun) do |str, ans|
          yield "の#{op[0]}が#{str}", ans
        end
      end
    end

    def digit(omega, &block)
      @whole = omega
               .map { |e| e.first.zero? ? nil : e.inject(0) { |a, c| a * 10 + c } }
               .compact
      multiply(&block)
    end
  end
end
