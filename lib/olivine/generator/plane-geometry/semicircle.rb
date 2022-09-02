module Olivine::Generator::PlaneGeometry
  class Semicircle < Base
    set_code 320
    set_label '半円と円周角'



    def expression
      @r = 76
      @m = 16

      well_behaved_angle(min: 30, max: 150) do |a|
        next unless a.even?

        abc = (180 - a) / 2
        c = Vector[@r, 0].rotate(a.to_radian)
        fig = figure([c], [[0,2],[1,2]])
        (2..10).each do |r|
          quiz = "#{fig}\n\n[[ref]]は, 長さ$#{2 * r}\\mathrm{cm}$の線分ABを直径とする半円Oの$\\arc{AB}$上に点Cを, $\\angle\\mathrm{ABC}=#{abc}^\\circ$となるようにとり, 点Aと点C, 点Bと点Cをそれぞれ結んだものである。\n\nこのとき, $\\arc{BC}$の長さを求めよ。ただし, 円周率は$\\pi$とする。"
          l = 2 * r * a.quo(360)
          ans = "$#{l.to_tex}\\pi\\mathrm{cm}$"
          yield quiz, ans if l.numerator < 100
        end
      end

      fraction do |t|
        fraction do |s|
          next if t < s || t - s < Rational(1, 3)

          a = Vector[-@r, 0]
          ob = Vector[@r, 0]
          c = ob.rotate(Math::PI * t)
          d = ob.rotate(Math::PI * s)
          e = PathFinder.intersection(a, ob, d, c)
          segments = [[0, 3], [1, 2]]

          condition = if 1 - t == s
                        segments << [2, 3]
                        format(
                          '$\\arc{AC}=%s\\arc{AB}$, $\mathrm{AB}\\jparallel\\mathrm{CD}$',
                          (1 - t).to_tex
                        )
                      else
                        format(
                          '$\\arc{AC}=%s\\arc{AB}$, $\\arc{BD}=%s\\arc{AB}$',
                          (1 - t).to_tex,
                          s.to_tex
                        )
                      end
          fig = figure([c, d, e], segments)
          joins = segments.map { |e| e.map{|c| "点#{(65 + c).chr}" }.join('と') }.join(', ')
          quiz = "#{fig}\n\n[[ref]]のように, 線分ABを直径とする半円Oの$\\arc{AB}$上に2点C, Dを, #{condition}となるようにとる。\n\n#{joins}をそれぞれ結び, 線分ADと線分BCの交点をEとする。\n\nこのとき, $\\angle\\mathrm{AEC}$の大きさを求めよ。"
          a = 90 * s + 90 * (1 - t)
          ans = "$#{a.to_tex}^\\circ$"
          yield quiz, ans if a.zahlen?

          if 1 - t == s
            abc = (90 * (1 - t))
            cod = 180 - abc * 4
            (1..10).each do |r|
              ab = 2 * r
              segments = [[0,3], [1,2], [2, 3]]
              fig = figure([c, d], segments)
              cond = format(
                       '$\\mathrm{AB}\\jparallel\\mathrm{CD}$, $\\angle\\mathrm{ABC}=%s^\\circ$',
                       abc.to_tex
                     )
              dim = format('$%d\\mathrm{cm}\$', ab)
              joins = segments.map { |e| e.map{|c| "点#{(65 + c).chr}" }.join('と') }.join(', ')

              quiz = "#{fig}\n\n[[ref]]は, 長さ#{dim}の線分ABを直径とする半円Oの$\\arc{AB}$上に2点C, Dを, #{cond}となるようにとり, #{joins}をそれぞれ結んだものである。\n\nこのとき, $\\arc{CD}$の長さを求めよ。ただし, 円周率は$\\pi$とする。"
              l = ab * cod.quo(360)
              ans = "$#{l.to_tex}\\pi\\mathrm{cm}$"
              yield quiz, ans if abc.zahlen?
            end
          end
        end
      end
    end

    def fraction
      (2..9).each do |den|
        (1...den).each do |num|
          q = num.quo(den)
          a = 180 * q
          yield q if num.prime_to?(den) && a.zahlen? && (30..150).cover?(a)
        end
      end
    end

    def figure(points = [], segments = [])
      r = @r
      m = @m
      wd = (r + m) * 2
      ht = r + m * 2
      fig_op = {
        width: wd,
        height: ht,
        viewBox: [
          -wd / 2,
          -ht + m,
          wd,
          ht
        ]
      }
      points.unshift(Vector[-r, 0], Vector[r, 0])
      origin = Vector[0, 0]
      svg = PathFinder.new(**fig_op) do
        path d: "M #{r} 0 A #{r} #{r} 0 0 0 #{-r} 0", class: 'thick'
        path d: "M #{r} 0 L #{-r} 0"
        dot origin
        label 'O', [0, m / 2]
        points.each_with_index do |p, i|
          dot p
          label (65 + i).chr, p + (p - origin).unit * m / 2
        end
        segments.each do |from, to|
          from_vec = points[from] || origin
          to_vec = points[to] || origin
          path d: "M #{from_vec.join} L #{to_vec.join}"
        end
      end

      svg.figure
    end
  end
end
