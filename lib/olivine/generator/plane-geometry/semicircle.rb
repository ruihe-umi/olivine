module Olivine::Generator::PlaneGeometry
  class Semicircle < Base
    set_code 320
    set_label "半円と円周角"

    RADIUS = 76
    MARGIN = 16
    FIXED_POINTS = {
      O: Vector[0, 0],
      A: Vector[-RADIUS, 0],
      B: Vector[RADIUS, 0]
    }
    PROVIDED = 'ただし，円周率は$\\pi$とする。'
    QUIZ1 = [
      ["AC", %w[BOC CAO BAC ACO]],
      ["BC", %w[AOC CBO ABC BCO]],
    ]

    Angle = Struct.new(:str, :_label, :size) do
      def to_s
        "\\angle\\mathrm{#{str}}"
      end

      def to_str
        str
      end

      def arc
        [a, c].sort
      end

      def label
        return _label if _label
        return "$#{size}^\\circ$" if size
      end
    end

    def points
      FIXED_POINTS.merge @vp
    end

    def angles(*args)
      args.map { |e| Angle.new(*e) }
    end

    def angle_size(ang)
      str = ang.to_str
      base = @params[@angles.index { |e| e.include?(str) }] || @params.inject(:-)
      case str
      when /(CD|DC)O/
        return (180 - base) / 2
      when "ACD"
        base += 180
      when "BDC"
        base = 360 - base
      when /A\w(C|D)|\wBO|B\wO/
        base = 180 - base
      end
      base /= 2 unless str[1] == "O"
      base
    end

    def expression(&block)
      @angles = [
        %w[
          BOC BAC BDC
          AOC ABC ADC
          BCO CBO CAO ACO
        ],
        %w[
          BOD BAD BCD
          AOD ABD ACD
          ADO BDO DAO DBO
        ],
        %w[
          COD CAD CBD
          CDO DCO
        ]
      ]

      well_behaved_angle(min:40, max: 90) do |bod|
        next unless bod.even?
        @params = [bod]
        quiz1(&block)
        well_behaved_angle(min: bod + 40, max: 140) do |boc|
          next unless boc.even?
          @params = [boc, bod]
          quiz2(&block)
        end
      end
    end

    def quiz1
      @vp = {C: Vector[RADIUS, 0].rotate(@params[0].to_radian)}
      QUIZ1.each do |l, angles|
        center = @params[0]
        center = 180 - center if l == 'AC'
        (1..10)
        .to_a
        .product(angles) do |r, angle|
          len = 2 * r * center.quo(360)
          size = @params[0]
          size = 180 - size if l == 'BC'
          size /= 2 unless angle[1] == 'O'
          next if len.numerator > 99 || size == 90
          ang = Angle.new(angle, "$#{size}^\\circ$")
          ans = "#{len.to_tex}\\pi\\mathrm{cm}"
          quiz = "#{figure([ang])}\n\n[[ref]]は, 長さ$#{2 * r}\\mathrm{cm}$の線分ABを直径とする半円Oの$\\arc{AB}$上に，点Cを$\\angle\\mathrm{#{angle}}=#{size}^\\circ$となるようにとったものである。\n\nこのとき, $\\arc{#{l}}$の長さを求めよ。ただし, 円周率は$\\pi$とする。"
          yield quiz, ans
        end
      end
    end

    def quiz2
      @vp = @params
            .map { |deg| [@params.index(deg).+(67).chr.to_sym, Vector[RADIUS, 0].rotate(deg.to_radian)] }
            .to_h

      @angles.size.times do |i|
        target, list1, list2 = @angles.rotate(i)
        list1.product(list2) do |a, b|
          unless a[1] == b[1]
            center = target.first
            angles = angles(a, b)
            cond = angles.map { |e| "$#{e}=#{angle_size(e)}^\\circ$" }.join("，")
            4.step(10, 2) do |l|
              yield "#{figure(angles)}\n\n[[ref]]は，長さ$#{l}\\rm cm$の線分$\\rm AB$を直径とする半円$\\rm O$において，$\\arc{AB}$上に点$\\rm C$を取り，$\\arc{BC}$上に点$\\rm D$を取ったものである。#{cond}のとき，$\\arc{#{center.sub(/(.).(.)/, '\\1\\2')}}$の長さを求めよ。#{PROVIDED}", "#{(l * angle_size(center)).quo(360).to_tex}\\pi\\rm cm"
            end
          end

          target.each do |c|
            next if [a, b, c].map { |e| e[1] }.uniq.size < 3
            angles = angles(a, b, [c, "$x$"])
            cond = angles[0..1].map { |e| "$#{e}=#{angle_size(e)}^\\circ$" }.join("，")
            yield "#{figure(angles)}\n\n[[ref]]は，線分$\\rm AB$を直径とする半円$\\rm O$において，$\\arc{AB}$上に点$\\rm C$を取り，$\\arc{BC}$上に点$\\rm D$を取ったものである。#{cond}のとき，$#{angles[2]}$の大きさを求めよ。", "#{angle_size(angles.last)}^\\circ"
          end
        end
      end
    end

    def figure(angles = [], segments = [])
      r = RADIUS
      m = MARGIN
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

      svg = PathFinder.new(**fig_op) do
        path d: "M #{r} 0 A #{r} #{r} 0 0 0 #{-r} 0", class: "thick"
        path d: "M #{r} 0 L #{-r} 0"
      end
      points.each do |key, val|
        svg.dot val
        svg.label key, key == :O ? [0, m / 2] : val + val.unit * m / 2
      end
      angles.each do |angle|
        vec = angle
              .str
              .chars
              .map { |k| points[k.to_sym] }
              .tap { |ang| ang.reverse! if reverse?(*ang) }
        label = angle.label
        label ||= (s = angle_size(angle.str)) == 90 ? nil : "$#{s}^\\circ$"
        svg.angle *vec, label, R: label.blank?
        segments.push([vec[0], vec[1]], [vec[1], vec[2]])
      end

      segments.uniq.each do |from, to|
        svg.path d: "M #{from.join} L #{to.join}"
      end

      svg.figure
    end

    def reverse?(from, vertex, to)
      # [from, to].map { |e| (e - vertex).arg }.minmax.inject(:-) < -Math::PI
      from, to = [from, to].map { |e| (e - vertex).arg }
      if from > to
        from - to < Math::PI
      else
        to - from > Math::PI
      end
    end
  end
end
