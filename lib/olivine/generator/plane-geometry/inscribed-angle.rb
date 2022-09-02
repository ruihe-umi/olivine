module Olivine::Generator::PlaneGeometry
  class InscribedAngle < Base
    set_code 300
    set_label '円周角の定理'


    RADIUS = 75
    MARGIN = 16

    def initialize
      @wd = (RADIUS + MARGIN) * 2
      @ht = @wd
      @points = {
        A: Vector[RADIUS, 0]
      }
    end

    def format_answer(angle)
      "$#{angle}^\\circ$"
    end

    def expression
      arcs = [
               ["BAC", "ACD"],
               ["BDC", "ABD"]
             ]
      inter = [
        "AEB",
        "AED",
        "CED",
        "BEC"
      ]
      @seg = ["AB", "AC", "BD", "CD"].map { |e| [e[0], e[1]].map(&:intern) }
      seed do |b, c, d|
        next unless [b, c, d].all? { |d| d.even? }
        @points[:E] = PathFinder.intersection(*@points.values_at(:A, :B, :C, :D))
        arcs.each do |ang|
          inter.each_with_index do |e, i|
            aeb = (c - b + 360 - d) / 2
            given = [
              [ang[0], (c - b) / 2],
              [ang[1], (360 - d) / 2],
              [e, i.odd? ? aeb : 180 - aeb]
            ]
            given.size.times {|i| yield *quiz(given.rotate(i)) }
          end
        end
      end
    end

    def quiz(angles)
      fig_ang = angles.map { |e| [e[0], "$#{e[1]}^\\circ$"] }.tap {|e| e[-1][1] = "$x$" }

      return format(
          "%s\n\n[[ref]]において，円周上に異なる4点A, B, C, Dがこの順に並んでいる。%sをそれぞれ結び, 線分ACと線分BDとの交点をEとする。$\\angle\\mathrm{%s}=%d^\\circ$, $\\angle\\mathrm{%s}=%d^\\circ$であるとき, $\\angle\\mathrm{%s}$の大きさを求めよ。",
          figure(@seg, fig_ang).figure,
          @seg.map { |e| e.map { |s| "点#{s}" }.join('と') }.join(', '),
          angles[0][0],
          angles[0][1],
          angles[1][0],
          angles[1][1],
          angles[2][0]
        ),
        angles[2][1]
    end

    def seed
      srand()
      interval = 60

      well_behaved_angle(min: 91, max: 269) do |c|
        next if c == 180
        @points[:A] = @points[:A].rotate(rand(360).to_radian)
        @points[:C] = @points[:A].rotate(c.to_radian)
        well_behaved_angle(min: interval, max: c - interval) do|b|
          next if [c - b, b].any?(180)
          @points[:B] = @points[:A].rotate(b.to_radian)
          well_behaved_angle(min: c + interval, max: 360 - interval) do|d|
            next if [d, d - b, d - c].any?(180)
            @points[:D] = @points[:A].rotate(d.to_radian)
            yield b, c, d
          end
        end
      end
    end

    def segment(*angles)
      angles
        .inject([]) { |a, c| a + [[c[0], c[1]], [c[2], c[1]]] }
        .map { |e| e.sort.map { |e| e.intern } }
        .uniq
        .sort
    end

    def figure(segments = [], angles = [])
      fig = PathFinder.new(
        width: @wd,
        height: @ht,
        viewBox: [
          -MARGIN - RADIUS,
          -MARGIN - RADIUS,
          @wd,
          @ht
        ]
      ) do
        circle cr: 0, cy: 0, r: RADIUS, class: 'thick'
      end
      @points.each_with_index do |(sym, pos), _index|
        fig.dot pos
        unless sym == :E
          fig.label "$\\mathrm{#{sym.to_s.upcase}}$", pos * (RADIUS + MARGIN / 2).fdiv(RADIUS)
        end
      end

      angles.each do |angle, label, ops|
        ops ||= {}
        ops[:R] ||= false
        arc = angle.chars.map { |e| @points[e.intern] }
        diff = (arc[2] - arc[1]).arg - (arc[0] - arc[1]).arg
        arc.reverse! unless (0..Math::PI).cover?(diff) || diff <= -Math::PI
        fig.angle *arc, label, **ops
        fig.angle *arc, "$\\mathrm{E}$", reverse: true, none: true, class: 'visible' if angle[1] == 'E'
      end

      pos = @points.transform_values(&:join)
      segments.each do |from, to|
        fig.path d: "M #{pos[from]} L #{pos[to]}"
      end

      fig
    end
  end
end
