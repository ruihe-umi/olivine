module Olivine::Generator::Probability
  class NumberOfCases
    def add(**arg)
      arg[:pop] ||= @pop.presence.dup
      arg[:figure] ||= @fig_method.presence
      @queue.push(arg)
    end

    def quiz
      @queue.each do |item|
        item_format = item[:str]
        pop = item[:pop].dup || {}
        pop_format = pop.delete(:str) || ''
        populate(**pop) do |pop|
          choise = item[:choise] || :repeated_permutation
          size = item[:size] || 2
          omega = pop.send(choise, size)
          ops = item[:op]
          ops = [ops] unless ops.is_a?(Array)
          fig = send("figure_#{item[:figure]}", pop) if item[:figure]
          pop_str = format(pop_format, pop.join(', '), pop.size)

          ops.each do |op|
            send(op, omega) do |quiz, ans|
              next unless ans.present?
              str = []
              str << fig if fig
              str << @prepend
              item_str = pop_str + format(item_format, quiz).gsub('[[size]]', pop.size.to_s)
              str << format(@format, item_str)

              ans = ans.quo(@whole.size) if @prob
              yield str.join("\n\n"), ans.to_tex
            end
          end
        end
      end
    end

    def populate(first: 1, size: 6, convert: :itself)
      f = first.is_a?(Integer) ? [first] : first.to_a
      s = size.is_a?(Integer) ? [size] : size.to_a
      f.product(s) do |n, m|
        if convert.is_a?(Array)
          convert.each { |p|
            yield Range.new(n, n + m - 1).map(&p)
          }
        else
          yield Range.new(n, n + m - 1).map(&convert)
        end
      end
    end

    def figure_balls(items)
      r = 12
      m = r / 2
      balls = case items.size
              when (1..3)
                items
              when 4
                items.each_slice(2)
              else
                items.reverse.each_slice(3).map { |e| e.sort }.reverse
              end

      ball_box = {
        width: balls.map(&:size).max * (r * 2 + m) - m,
        height: balls.size * (r * 2 + m) - m
      }
      slant = 12
      y_shift = slant * 4
      wd = ball_box[:width] + 6 * m
      ht = ball_box[:height] + 2 * m + y_shift
      mouth_wd = wd / 3
      mouth_x = -mouth_wd
      ball_box[:x] = -ball_box[:width].fdiv(2)
      ball_box[:y] = y_shift
      tangent = [
        mouth_x + r / 6,
        r / 3
      ]
      outward = [
        tangent,
        [mouth_x + r, y_shift / 3],
        [mouth_x, (2 * y_shift) / 3],
        [mouth_x - r, y_shift],
        [-wd / 2, (y_shift + ht / 2) / 2],
        [-wd / 2 - m, ht / 2],
        [-wd / 2 - 1.5 * m, ht * 2 / 3],
        [-wd / 2 - 1.75 * m, ht - 3 * m],
        [-wd / 2 - m, ht - m],
        [-wd / 2, ht]
      ]
      points = [*outward, [0, ht]] + outward.map { |x, y| [-x, y] }.reverse
      start = points.shift
      commands = "M #{start.join(' ')} " + points.each_slice(2).map { |e| e.unshift('Q') }.join(' ')

      fig = Olivine::PathFinder.new(
        width: wd + 4 * m,
        height: ht + slant,
        class: 'prob-list',
        viewBox: [
          -wd.fdiv(2) - 2 * m,
          -slant,
          wd + 4 * m,
          ht + slant
        ]
      ) do
        ellipse cx: 0, cy: 0, rx: mouth_wd, ry: slant
        path d: commands

        balls.each_with_index do |row, rid|
          cy = rid * (r * 2 + m) + r + ball_box[:y]
          ball_shift_x = -(row.size * (2 * r + m) - m).fdiv(2)
          row.each_with_index do |col, cid|
            cx = cid * (r * 2 + m) + r + ball_shift_x
            circle cx: cx, cy: cy, r: r
            text col, x: cx, y: cy
          end
        end
      end

      fig.figure
    end

    def figure_cards(items)
      wd = 32
      ht = 32
      mr = wd * 0.25
      fig = Olivine::PathFinder.new(
        width: (wd + mr) * items.size - mr,
        height: ht,
        class: 'prob-list'
      ) do
        items.each_with_index do |item, index|
          rect x: (wd + mr) * index, y: 0, width: wd, height: ht
          text item, x: (wd + mr) * index + wd / 2, y: ht / 2
        end
      end
      fig.figure
    end
  end
end
