module Olivine::Generator::SpaceGeometry
  class ConeBall < Base
    set_code 120
    set_label '円錐・円柱・球'

    MAX_LENGTH = 10
    SLANT_WIDTH = 20

    def _expression(&block)
      cones(&block)
      balls(&block)
      cylinders(&block)
    end

    def cylinders
      (3...MAX_LENGTH).each do |radius|
        radius.upto(MAX_LENGTH) do |height|
          aspect = height.fdiv(2 * radius)
          wd, ht = aspect < 1.5 ? [120, 120 * aspect] : [180 / aspect, 180]
          rd = wd / 2
          fig_op = {
            width: wd,
            height: ht + 2 * SLANT_WIDTH,
            viewBox: [-rd, -SLANT_WIDTH, wd, ht + 2 * SLANT_WIDTH]
          }
          fig = PathFinder.new(**fig_op) do
            ellipse  cx: 0, cy: 0, rx: rd, ry: SLANT_WIDTH, class: "thick"
            length Vector[rd, ht], Vector[0, ht], "$#{radius}\\textrm{cm}$", line: true
            length Vector[0, ht], Vector[0, 0], "$#{height}\\textrm{cm}$", line: true, label_sep: 20

            path d: "M #{rd} #{ht} A #{rd} #{SLANT_WIDTH} 0 0 0 #{-rd} #{ht}", class: 'dashed helpline'
            path d: "M #{-rd} #{ht} A #{rd} #{SLANT_WIDTH} 0 0 0 #{rd} #{ht}", class: 'thick'
            path d: "M #{-rd} 0 v #{ht} M #{rd} 0 v #{ht}", class: 'thick'
            angle Vector[rd, ht], Vector[0, ht], Vector[0, 0], class: 'visible'
            dot Vector[0, 0]
            dot Vector[0, ht]
          end.figure

          yield "#{fig}\n\n半径$#{radius}\\textrm{cm}$，高さ$#{height}\\textrm{cm}$の円柱の体積を求めよ。", "#{radius**2 * height}\\pi\\textrm{cm}^3"
          yield "#{fig}\n\n半径$#{radius}\\textrm{cm}$，高さ$#{height}\\textrm{cm}$の円柱の表面積を求めよ。", "#{2*radius * (radius + height)}\\pi\\textrm{cm}^2"
        end
      end
    end

    def balls
      (3..MAX_LENGTH).each do |radius|
        fig_op = {
          width: 120,
          height: 120,
          viewBox: [-60, -60, 120, 120]
        }
        origin = Vector[0, 0]
        fig = PathFinder.new(**fig_op) do
          length Vector[60, 0], origin, "$#{radius}\\textrm{cm}$", line: true
          circle cx: 0, cy: 0, r: 60, class: 'thick'
          ellipse cx: 0, cy: 0, rx: 60, ry: SLANT_WIDTH, class: %w[helpline dashed]
          dot origin
        end.figure

        quiz = "#{fig}\n\n半径$#{radius}\\textrm{cm}$の球の体積を求めよ。"
        vol = "#{(4 * radius**3).quo(3).to_tex}\\pi\\textrm{cm}^3"
        yield quiz, vol

        quiz = "#{fig}\n\n半径$#{radius}\\textrm{cm}$の球の表面積を求めよ。"
        sur = "#{4 * radius**2}\\pi\\textrm{cm}^2"
        yield quiz, sur
      end
    end

    def cones
      (3..MAX_LENGTH).each do |radius|
        radius.upto(MAX_LENGTH) do |height|
          quiz = <<~EOF
            #{draw_cone(r: radius, h: height)}

            半径$#{radius}\\textrm{cm}$，高さ$#{height}\\textrm{cm}$の円すいの体積を求めよ。
          EOF
          vol = "#{(radius**2 * height).quo(3).to_tex}\\pi\\textrm{cm}^3"
          yield quiz, vol

          unless slant = (radius**2 + height**2).square
            unless radius - height >= 2 || (height**2 - radius**2).square?
              quiz = <<~EOF
                #{draw_cone(r: radius, s: height)}

                半径$#{radius}\\textrm{cm}$，母線の長さ$#{height}\\textrm{cm}$の円すいの表面積を求めよ。
              EOF
              yield quiz, "#{radius * height}\\pi\\textrm{cm}^2"
            end
            next
          end

          cone_rs = draw_cone(r: radius, s: slant)
          quiz = <<~EOF
            #{cone_rs}

            半径$#{radius}\\textrm{cm}$，母線の長さ$#{slant}\\textrm{cm}$の円すいの体積を求めよ。
          EOF
          yield quiz, vol

          quiz = <<~EOF
            #{cone_rs}

            半径$#{radius}\\textrm{cm}$，母線の長さ$#{slant}\\textrm{cm}$の円すいの表面積を求めよ。
          EOF
          sur = "#{radius * slant}\\pi\\textrm{cm}^2"
          yield quiz, sur

          cone_hs = draw_cone(h: height, s: slant)
          quiz = <<~EOF
            #{cone_hs}

            高さ$#{height}\\textrm{cm}$，母線の長さ$#{slant}\\textrm{cm}$の円すいの体積を求めよ。
          EOF
          yield quiz, vol

          quiz = <<~EOF
            #{cone_hs}

            高さ$#{height}\\textrm{cm}$，母線の長さ$#{slant}\\textrm{cm}$の円すいの表面積を求めよ。
          EOF
          yield quiz, sur
        end
      end
    end

    def draw_cone(r: nil, h: nil, s: nil)
      nil_count = [r, h, s].count(nil)
      if nil_count > 1
        raise ArgumentError,
              'to less parameters (at least 2 required)'
      end
      if nil_count == 0 && r**2 + h**2 != s**2
        raise ArgumentError,
              'wrong parameters'
      end

      radius = r.presence || Math.sqrt(s**2 - h**2)
      height = h.presence || Math.sqrt(s**2 - r**2)
      aspect = height.fdiv(2 * radius)

      wd, ht = aspect < 1.5 ? [120, 120 * aspect] : [180 / aspect, 180]
      rd = wd / 2
      apex = Vector[0, -ht]
      pot_y = -(SLANT_WIDTH**2).fdiv(ht)
      pot_x = Math.sqrt(rd**2 * (1 - (pot_y / SLANT_WIDTH)**2))
      pot_l = Vector[-pot_x, pot_y]
      pot_r = Vector[pot_x, pot_y]
      right = Vector[rd, 0]
      origin = Vector[0, 0]
      fig_op = {
        width: wd,
        height: ht + SLANT_WIDTH,
        viewBox: [
          -rd,
          -ht,
          wd,
          ht + SLANT_WIDTH
        ]
      }
      fig = PathFinder.new(**fig_op) do
        if h
          length origin, apex, "$#{h}\\textrm{cm}$"
          path d: "M #{origin.join} L #{apex.join}", class: 'dashed helpline'
        end

        if r
          length right, origin, "$#{r}\\textrm{cm}$"
          path d: "M #{origin.join} L #{right.join}", class: 'dashed helpline'
        end

        length apex, right, "$#{s}\\textrm{cm}$", label_sep: 16 if s

        angle right, origin, apex, R: true, class: 'visible' if h
        dot origin unless h

        path d: "M #{pot_r.join} A #{rd} #{SLANT_WIDTH} 0 0 0 #{pot_l.join}", class: 'dashed helpline'
        path d: "M #{pot_l.join} A #{rd} #{SLANT_WIDTH} 0 1 0 #{pot_r.join} L #{apex.join} Z", class: 'thick'
      end

      fig.figure
    end
  end
end
