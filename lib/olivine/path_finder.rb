module Olivine
  class PathFinder < Victor::SVG
    attr_accessor :label_sep

    LABEL_DIRECTION = {
      above: [0, -1],
      above_left: [-0.707106781185, -0.707106781185],
      left: [-1, 0],
      below_left: [-0.707106781185, 0.707106781185],
      below: [0, 1],
      below_right: [0.707106781185, 0.707106781185],
      right: [1, 0],
      above_right: [0.707106781185, -0.707106781185],
    }

    # <b>四辺形ABCD</b>における対角線の交点を求める
    def self.intersection(a, b, c, d)
      den = (c - a).times(d - b)
      raise "2 lines are parallel" if den.zero?
      s = (b - a).times(d - b).fdiv(den)
      t = (c - a).times(a - b).fdiv(den)
      raise "2 segments have no intersection" unless [s, t].all? { |e| (0..1).cover?(e) }

      a + s * (c - a)
    end

    def initialize(**arg)
      @label_sep = 12
      arg[:template] ||= :minimal
      super(**arg)
    end

    def label(text, pos = nil, **ops)
      ops ||= {}
      unless pos.blank?
        ops[:x] = pos[0]
        ops[:y] = pos[1]
      end

      foreignObject(**ops) do
        span text
      end
    end

    def origin
      Vector[0, 0]
    end

    def angle(start, vertex, finish, label = nil, **ops)
      ops ||= {}
      ops[:class] ||= []
      unless ops[:class].is_a?(Array)
        str = ops[:class]
        ops[:class] = [str]
      end
      ops[:class] << 'angle'
      label_sep = ops.delete(:label_sep)
      label_sep ||= @label_sep
      none = ops.delete(:none)
      reverse = ops.delete(:reverse)

      vs = (start - vertex).unit * label_sep
      vf = (finish - vertex).unit * label_sep
      s = vertex + vs
      f = vertex + vf
      (angle = vf.arg - vs.arg).negative? && angle += Math:: PI * 2
      is_right = ops.delete(:R)
      is_right.nil? && is_right = angle * 2 == Math::PI

      g(**ops) do
        is_large = angle > Math::PI ? '1' : '0'
        unless none
          if is_right
            path d: "M #{s.join} l #{vf.join} l #{(-vs).join}"
          else
            path d: "M #{s.join} A #{label_sep} #{label_sep} 0 #{is_large} 0 #{f.join}"
          end
        else
          if is_right
            path d: "M #{vertex.join} l #{vs.join} l #{vf.join} l #{(-vs).join} z", class: ["none"]
          else
            path d: "M #{vertex.join} l #{vs.join} A #{label_sep} #{label_sep} 0 #{is_large} 0 #{f.join} z", class: ["none"]
          end
        end

        if label.present?
          label_pos = LABEL_DIRECTION[ops.delete(:label_pos)]
          v = label_pos ? Vector[*label_pos] * label_sep : vs.rotate(angle / 2) * 2
          if reverse
            reverse.kind_of?(Numeric) ? v *= -reverse : v /= -2
          end
          vl = v + vertex
          label label, x: vl[0], y: vl[1], class: 'label-angle'
        end
      end
    end

    def dot(position, **ops)
      ops ||= {}
      ops[:class] = [ops[:class]] unless ops[:class].is_a?(Array)
      ops[:class] << 'dot'
      circle cx: position[0], cy: position[1], r: '0.6mm', **ops
    end

    def length(start, finish, label, **ops)
      ops ||= {}
      label_sep = ops.delete(:label_sep)
      label_sep ||= @label_sep
      draw_path = ops.delete(:line) && "Z"
      v = finish - start
      n = v.rotate(Math::PI / 2).unit * label_sep
      midway = (start + finish) / 2
      label_pos = midway + n
      control = midway + n * 2
      g(**ops) do
        path d: "M #{start.join} Q #{control.join} #{finish.join} #{draw_path}", class: 'dashed'
        label label, x: label_pos[0], y: label_pos[1], class: 'label-length'
      end
    end

    def figure
      "<figure>#{render}</figure>".gsub("\n", '')
    end
  end
end
