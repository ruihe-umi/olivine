require 'forwardable'

module Olivine::Generator::Probability
  TableRow = Struct.new(:min, :max, :count) do
    def value
      (min + max) / 2
    end

    def range
      (min...max)
    end

    def cover?(datum)
      range.cover?(datum)
    end
  end

  class DataTable
    extend Forwardable
    attr_accessor :rows, :data
    attr_reader :interval
    def_delegators :@data, :min, :max, :minmax, :size, :count
    def_delegators :@rows, :each, :find, :select

    def initialize(data, interval: nil, min: nil, unit: nil)
      @data = data.sort
      @unit = unit || ['回', '人']
      min ||= @data.min
      max = @data.max
      @interval = interval || (max - min) / (1 + Math.log2(@data.size)).round
      cls = []
      cls << [min, min + interval]
      until (floor = cls.last[1]) > max
        cls << [floor, floor + interval]
      end
      @rows = cls.map do |min, max|
                TableRow.new(min, max, @data.count do |e|
                                         (min...max).cover?(e)
                                       end)
              end.drop_while { |r| r.count.zero? }
    end

    def sum
      @rows.inject(0) { |a, r| a + r.count * r.value }
    end

    def show
      @data.join(',')
    end

    def mean
      if sum.modulo(size).zero?
        sum / size
      else
        sum.to_d.quo(size)
      end
    end

    def mode
      cnt = @rows.map { |e| e.count }.max
      @rows.select { |e| e.count == cnt }.map { |e| e.value }
    end

    def median
      if size.odd?
        @rows.find { |r| r.cover?(@data[size / 2]) }.value
      else
        ceil = @rows.find { |r| r.cover?(@data[size / 2]) }.value
        floor = @rows.find { |r| r.cover?(@data[size / 2 - 1]) }.value
        (sum = ceil + floor).even? ? sum / 2 : sum.to_d.div(2, 1)
      end
    end

    def variance
      x_ = sum.fdiv(size)
      @rows.inject(0.0) { |a, r| a + r.count * (r.value - x_) ** 2 }.fdiv(size)
    end

    def kurtosis
      x_ = sum.fdiv(size)
      sd = Math.sqrt(variance)
      @rows.inject(0.0) { |a, r| a + r.count * ((r.value - x_) / sd)**4 }.fdiv(size)
    end

    def to_table(unit = '')
      tbl = []
      tbl << ["階級(#{@unit[0]})", "度数(#{@unit[1]})"]
      tbl << [':-:', ':-:']
      tbl << ['以上　未満', '']
      @rows.each do |row|
        rstr = format('%3d ～ %3d', row.min, row.max)
        tbl << [rstr, row.count]
      end
      tbl << [':-:', ':-:']
      tbl << ['計', size]

      "<figure markdown=\"1\" class=\"frequency\">\n\n#{tbl.map { |c, f| "|#{c}|#{f}|" }.join("\n")}\n\n</figure>"
    end

    def to_histogram
      bar_wd = 24
      col_ht = 12
      plot_wd = bar_wd * (@rows.size + 2)
      max_col = (m = find{|r| r.value == mode[0] }.count).even? ? m + 2 : m + 1
      plot_ht = col_ht * max_col
      wd = plot_wd + 40
      ht = plot_ht + 48
      unit = @unit
      rows = @rows
      fig = Olivine::PathFinder.new(
        width: wd,
        height: ht,
        viewBox: [
          -24,
          -ht + 16,
          wd,
          ht
        ],
        class: "histogram"
      ) do
          rect x: 0, y: -plot_ht, width: plot_wd, height: plot_ht
          0.step(max_col, 2) do |i|
            y = i * -col_ht
            line x1: 0, y1: y, x2: plot_wd, y2: y
            text i, x: -8, y: y
          end
          text "(#{unit[1]})", x: -8, y: -plot_ht - 16

          0.upto(rows.size - 1) do |j|
            x = j.succ * bar_wd
            h = rows[j].count * col_ht
            rect x: x, y: -h, width: bar_wd, height: h, class: "painted"
            text rows[j].min, x: x, y: 8
          end
          text rows.last.max, x: plot_wd - bar_wd, y: 8
          text "(#{unit[0]})", x: plot_wd, y: 8
      end

      fig.figure
    end
  end
end
