module Olivine::Generator::PlaneGeometry
  class Parallel < Base
    set_code 200
    set_label '平行線と角'



    GRACEFUL_ANGLE = (30..150).reject { |e| e.prime_to?(180) || e == 90 }

    def expression
      @ht = 90
      @wd = 150
      @sep = 8

      GRACEFUL_ANGLE.permutation(2) do |a, b|
        next unless a < 90 && (b - a).abs > 30
          two_line(a, b) do |q, a|
            yield "#{q}\n\n[[ref]]で, $\\ell\\jparallel m$のとき, $\\angle{x}$の大きさを求めよ。",
                  "#{a}^\\circ"
          end
      end
      GRACEFUL_ANGLE.repeated_combination(2) do |a, c|
        next if [a, c].any? { |e| e > 90 }
        1.upto(10) do |i|
        b = 15 * i
          if [a, c].all?{ |e| b > 90 ? b < e + 150 : b < e - 30 }
            three_line(a, b, c) do |q, a|
              yield "#{q}\n\n[[ref]]で, $\\ell\\jparallel m$のとき, $\\angle{x}$の大きさを求めよ。",
                    "#{a}^\\circ"
            end
          end
        end
      end
    end

    def two_line(above, below)
      a = above.to_radian
      b = below.to_radian
      p = {}
      ht2 = @ht / 2
      sep_h = Vector[@sep, 0]
      wd = @wd + @sep * 2
      ht = @ht + @sep * 2
      hline_wd = @wd

      p[:B] = Vector[0, ht2]
      p[:A] = p[:B] + Vector[ht2 / Math.tan(a), -ht2]
      p[:C] = p[:B] + Vector[ht2 / -Math.tan(b), ht2]
      g = p.inject(Vector[0, 0]) { |a, (k, v)| a + v } / 3
      p[:l] = g - Vector[@wd, @ht] / 2
      p[:m] = p[:l] + Vector[0, @ht]
      p[:m_end] = p[:m] + Vector[@wd, 0]

      x_angle = above + 180 - below
      fig1 = PathFinder.new(
        width: wd,
        height: ht,
        viewBox:[
          p[:l][0] - @sep * 2,
          p[:l][1] - @sep,
          wd,
          ht
          ]) do
        label '$\\ell$', p[:l] - sep_h
        label '$m$', p[:m] - sep_h
        path d: "M #{p[:l].join} h #{hline_wd}"
        path d: "M #{p[:m].join} h #{hline_wd}"
        path d: "M #{p[:A].join} L #{p[:B].join} L #{p[:C].join}"
        angle p[:l], p[:A], p[:B], "$#{above}^\\circ$", class: 'visible'
        if x_angle < 180
          angle p[:C], p[:B], p[:A], "$x$", R: false, class: 'visible'
        else
          angle p[:A], p[:B], p[:C], "$x$", R: false, class: 'visible'
        end
        if below < 90
          angle p[:m_end], p[:C], p[:B], "$#{below}^\\circ$", class: 'visible'
        else
          angle p[:B], p[:C], p[:m], "$#{180 - below}^\\circ$", class: 'visible'
        end
      end
      (ans = x_angle) > 180 && ans = 360 - ans

      yield fig1.figure, ans

      p.clear
      p[:B] = Vector[0, 0]
      p[:A] = Vector[-ht2 / Math.tan(a), ht2]
      p[:C] = Vector[-@ht / Math.tan(b), @ht]
      g = p.inject(Vector[0, 0]) { |a, (k, v)| a + v } / 3
      p[:l] = g - Vector[@wd, @ht] / 2 + Vector[0, ht2]
      p[:m] = p[:l] + Vector[0, ht2]
      p[:l_end] = p[:l] + Vector[@wd, 0]
      p[:m_end] = p[:m] + Vector[@wd, 0]

      wd_range = (p[:l][0] + @sep..p[:l_end][0] - @sep)
      return unless [p[:A], p[:B], p[:C]].all? {|e| wd_range.cover?(e[0]) }

      ht += @sep
      x_angle = below - above
      fig2 = PathFinder.new(
        width: wd,
        height: ht,
        viewBox:[
          p[:l][0] - @sep * 2,
          -@sep * 2,
          wd,
          ht
          ]) do
        if x_angle < 45 && below > above
          angle p[:l_end], p[:A], p[:B], "$#{above}^\\circ$", label_pos: :above_left, class: 'visible'
        else
          angle p[:l_end], p[:A], p[:B], "$#{above}^\\circ$", class: 'visible'
        end
        if x_angle.negative?
          angle p[:C], p[:B], p[:A], "$x$", reverse: 0.25, R: false, class: 'visible'
          x_angle = -x_angle
        else
          angle p[:A], p[:B], p[:C], "$x$", reverse: 0.25, R: false, class: 'visible'
        end
        if below < 90
          angle p[:m_end], p[:C], p[:B], "$#{below}^\\circ$", class: 'visible'
        else
          angle p[:B], p[:C], p[:m], "$#{180 - below}^\\circ$", class: 'visible'
        end

        label '$\\ell$', p[:l] - sep_h
        label '$m$', p[:m] - sep_h
        path d: "M #{p[:l].join} h #{hline_wd}"
        path d: "M #{p[:m].join} h #{hline_wd}"
        path d: "M #{p[:A].join} L #{p[:B].join} L #{p[:C].join}"
      end

      yield fig2.figure, x_angle
    end

    def three_line(above, middle, below)
      a = above.to_radian
      b = middle.to_radian
      c = below.to_radian
      p = {}
      ht3 = @ht / 3
      sep_h = Vector[@sep, 0]
      wd = @wd + @sep * 2
      ht = @ht + @sep * 2
      hline_wd = @wd

      p[:A] = Vector[0, 0]
      if middle < 90
        p[:B] = Vector[-2 * ht3 / Math.tan(a), 2 * ht3]
        p[:C] = p[:B] + Vector[ht3 / Math.tan(b), -ht3]
        p[:D] = p[:C] + Vector[2 * ht3 / -Math.tan(c), 2 * ht3]
      else
        p[:B] = Vector[-ht3 / Math.tan(a), ht3]
        p[:C] = p[:B] + Vector[ht3 / -Math.tan(b), ht3]
        p[:D] = p[:C] + Vector[ht3 / -Math.tan(c), ht3]
      end
      m = (p[:B] + p[:C]) / 2
      p[:l] = m - Vector[@wd, @ht] / 2
      p[:m] = p[:l] + Vector[0, @ht]
      p[:m_end] = p[:m] + Vector[@wd, 0]

      return unless [p[:A],p[:B],p[:C],p[:D]].all? { |e| p[:l][0] + @sep < e[0] && e[0] < p[:m_end][0] -@sep }

      (x_angle = above - middle).negative? && x_angle = 180 - x_angle
      (c_angle = below - middle).negative? && c_angle = 180 + c_angle
      fig1 = PathFinder.new(
        width: wd,
        height: ht,
        viewBox:[
          p[:l][0] - @sep * 2,
          p[:l][1] - @sep,
          wd,
          ht
          ]) do
        label '$\\ell$', p[:l] - sep_h
        label '$m$', p[:m] - sep_h
        path d: "M #{p[:l].join} h #{hline_wd}"
        path d: "M #{p[:m].join} h #{hline_wd}"

        path d: "M #{p[:A].join} L #{p[:B].join} L #{p[:C].join} L #{p[:D].join}"
        angle p[:l], p[:A], p[:B], "$#{above}^\\circ$", class: 'visible'
        angle p[:C], p[:B], p[:A], "$x$", R: false, class: 'visible'
        angle p[:B], p[:C], p[:D], (c_angle == 90 ? "" : "$#{c_angle}^\\circ$"), class: 'visible'
        angle p[:m_end], p[:D], p[:C], "$#{below}^\\circ$", class: 'visible'
      end
      (ans = x_angle) > 180 && ans = 360 - ans

      yield fig1.figure, ans
    end
  end
end
