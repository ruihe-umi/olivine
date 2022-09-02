module Olivine::Generator::SignedNumber
  # 正負の数　四則混合
  # 問題を作成する
  # * 分数と整数の乗除＋整数の形
  # * 整数は-9～9（ただし0を除く）
  # * 必ず約分ができて、答えが整数になるものに限る
  class Fraction < Base
    set_label '四則混合(分数)'
    set_code 200

    

    def expression
      products do |p, v|
        DIGIT.each do |i|
          yield "#{p}+#{i}", (v + i).truncate
          yield "#{i}+#{p}", (i + v).truncate
        end
      end
    end

    def products
      frac(9, only_proper: false) do |fraction|
        next if fraction.numerator.abs == 1

        int do |i, v|
          p = fraction * v
          is_single = (v / fraction.denominator).abs < 10
          if p.zahlen? && is_single && fraction.proper?
            yield "#{i}*#{fraction.to_tex}", p
            yield "#{fraction.to_tex}*#{i.to_tex}", p
          end
          q = v.quo(fraction)
          is_single = (v / fraction.numerator).abs < 10
          yield "#{i}/#{fraction.to_tex}", q if q.zahlen? && is_single
        end
      end
    end

    def int
      DIGIT.each { |i| yield i, i }

      [
        '2**2',
        '2**3',
        '-2**2',
        '(-2)**2',
        '(-2)**3',
        '3**2',
        '-3**2',
        '(-3)**2',
        '4**2',
        '-4**2',
        '(-4)**2',
        '6**2',
        '-6**2',
        '(-6)**2'
      ].each { |e| yield e, eval(e) }
    end
  end
end
