module Olivine::Generator::PlaneGeometry
  class InscribedAngleDiameter < Base
    set_code 310
    set_label '直径と円周角'



    RADIUS = 75
    MARGIN = 16
    FORMAT = "%s\n\n[[ref]]は, 線分ABを直径とする円Oの周上に, 2点A, Bと異なる点Cをとり, 点Cを含まない$\\arc{AB}$上に点Dを$\\angle\\mathrm{%s}=%d^\\circ$となるようにとったものである。$\\angle\\mathrm{%s}の大きさを求めよ。$"
    FORMAT_2 = "%s\n\n[[ref]]は, 線分ABを直径とする円Oの周上に, 2点A, Bと異なる点Cをとり, 点Cを含まない$\\arc{AB}$上に点Dを$%s\\arc{AC}=%s\\arc{BD}$となるようにとったものである。\n\n直径ABと線分CDとの交点をEとする。\n\n$\\angle\\mathrm{%s}=%d^\\circ$のとき, $\\angle\\mathrm{%s}の大きさを求めよ。$"

    def initialize
      @wd = (RADIUS + MARGIN) * 2
      @ht = @wd
      @points = {
        A: Vector[-RADIUS, 0],
        B: Vector[RADIUS, 0],
        O: Vector[0, 0]
      }
    end

    def format_answer(angle)
      "$#{angle}^\\circ$"
    end

    def expression
      well_behaved_angle(min: 30, max: 150)
        .to_a
        .permutation(2) do |aoc, bod|
        @points[:C] = @points[:A].rotate(aoc.to_radian)
        @points[:D] = @points[:B].rotate(bod.to_radian)
        @points.delete(:E)

        if aoc.even?
          a = aoc / 2
          b = 90 - a
          yield quiz('ADC', a, 'BAC'), b
          yield quiz('ADC', a, 'BOC'), b * 2
          yield quiz('BDC', b, 'ABC'), a
          yield quiz('BDC', b, 'AOC'), a * 2
        end

        if bod.even?
          a = bod / 2
          b = 90 - a
          yield quiz('ABD', b, 'BCD'), a
          yield quiz('ADO', a, 'ACD'), b
          yield quiz('BDO', b, 'BCD'), a
          yield quiz('BAD', a, 'ACD'), b
          yield quiz('BCD', a, 'ABD'), b
          yield quiz('BCD', a, 'AOD'), b * 2
        end

        quadrilateral = [@points[:A], @points[:C], @points[:B], @points[:D]]
        @points[:E] = PathFinder.intersection(*quadrilateral)
        q, r = [aoc, bod].minmax.inject { |min, max| max.divmod(min) }
        if r.zero? && bod.even? && aoc.even?
          ratio = aoc >= bod ? [1, q] : [q, 1]
          aec = (aoc + bod) / 2
          angles = {
            'ABC' => (abc = aoc / 2),
            'ADC' => abc,
            'ABD' => (abd = (180 - bod) / 2),
            'ACD' => abd,
            'BAC' => bdc = (180 - aoc) / 2,
            'BDC' => bdc,
            'BAD' => bad = bod / 2,
            'BCD' => bad,
          }
          angles.each do |key, val|
            yield quiz2('AEC', aec, ratio, key), val
            yield quiz2(key, val, ratio, 'AEC'), aec
          end
        end
      end
    end

    def quiz(given, size, answer)
      angles = [
        [given, "$#{size}^\\circ$"],
        [answer, '$x$']
      ]
      format(
        FORMAT,
        figure(segment(given, answer), angles).figure,
        given,
        size,
        answer
      )
    end

    def quiz2(given, size, ratio, answer)
      angles = [
        [given],
        [answer, '$x$']
      ]
      if size == 90
        angles[0].push nil, { R: true }
      else
        angles[0] << "$#{size}^\\circ$"
      end
      sgm = segment(given, answer)
            .reject { |e| [%i[C E], %i[D E], %i[C D]].include?(e) }
            .push(%i[C D])
      fig = figure(sgm, angles)
      fig.dot @points[:E]
      fig.label "$\\mathrm{E}$", @points[:E] + (size > 90 ? Vector[8, -8] : Vector[-8, -8])
      format(
        FORMAT_2,
        fig.figure,
        *ratio.map { |e| e == 1 ? '' : e.to_tex },
        given,
        size,
        answer
      )
    end

    def segment(*angles)
      angles
        .inject([]) { |a, c| a + [[c[0], c[1]], [c[2], c[1]]] }
        .map { |e| e.sort.map { |e| e.intern } }
        .reject { |e| [%i[A O], %i[B O], %i[A B]].include?(e) }
        .uniq
        .sort
    end

    def figure(segments = [], angles)
      if (rd = segments.find { |e| e.include?(:O) }).nil?
        oh = segments.map { |a, b| (@points[a] + @points[b]) / 2 }.min { |a, b| a.r <=> b.r }
        o_label = [0, oh[1].negative? ? 8 : -8]
      else
        o_label = [0, @points[rd[0]][1].negative? ? 8 : -8]
      end

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
        dot [0, 0]
        label '$\\mathrm{O}$', o_label
      end
      @points.each_with_index do |(sym, pos), _index|
        next if [:O, :E].include?(sym)

        fig.dot pos
        fig.label "$\\mathrm{#{sym.to_s.upcase}}$", pos * (RADIUS + MARGIN / 2).fdiv(RADIUS)
      end

      angles.each do |angle, label, ops|
        ops ||= {}
        ops[:R] ||= false
        arc = angle.chars.map { |e| @points[e.intern] }
        diff = (arc[2] - arc[1]).arg - (arc[0] - arc[1]).arg
        arc.reverse! unless (0..Math::PI).cover?(diff) || diff <= -Math::PI
        fig.angle(*arc, label, **ops)
      end

      pos = @points.transform_values(&:join)
      segments.each do |from, to|
        fig.path d: "M #{pos[from]} L #{pos[to]}"
      end
      fig.path d: "M #{pos[:A]} L #{pos[:B]}"

      fig
    end
  end
end
