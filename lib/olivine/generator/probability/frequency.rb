require 'bigdecimal/util'
require_relative 'data-table.rb'
require_relative 'stats.rb'

module Olivine::Generator::Probability
  class Frequency < Base
    set_code 210
    set_label '度数分布表'

    

    def initialize
      @figure_method = :to_table
      @figure_name = "度数分布表"
    end

    def expression
      Stats::PHYSICALS.each do |pop|
        item = pop.dup
        @label = item.delete(:label)
        unit = item.delete(:unit)
        12.step(30, 3) do |size|
          @size = size
          data = []
          while true
            raw_data = Stats.random_data(size: size, **item)
            data = data_transform(raw_data, [unit, '人'])
            break if data.rows.size < 8 &&
                     data.mode.size == 1 &&
                     (data.kurtosis - 3).abs <= 1.96 * Math.sqrt(24.fdiv(size))
          end
          @figure = data.send(@figure_method)
          yield quiz('最頻値'), data.mode[0]
          yield quiz('中央値'), data.median

          prov, ans, fstr = provided(data.mean)
          yield quiz('平均値', prov), format(fstr, ans)

          data.each do |row|
            rel = row.count.to_d.div(size, 4)
            if rel.positive? && rel.digit < 3
              target = format('%d%sの記録を含む階級の相対度数', row.value, unit)
              yield quiz(target, '小数で'), rel.to_s('f')
              percent = format('%d%sの記録を含む階級に属する人の人数', row.value, unit)
              yield blank(percent, '%'), (rel * 100).to_i
            end
            cum = data.count { |v| v < row.max }.to_d.div(size, 4)
            if cum > 0 && cum < 1 && cum.digit < 3
              ans = cum < 0.5 ? cum : 1 - cum
              s = cum < 0.5 ? '未満' : '以上'
              target = format('%sの記録が%d%s%sであった人の人数', @label, row.max, unit, s)
              yield blank(target, '%'), (ans * 100).to_i
              frequency = format('記録が%d%s%sであった人の相対度数', row.max, unit, s)
              yield quiz(frequency, '小数で'), ans.to_s('f')
            end
          end
        end
      end
    end

    def provided(answer, max_digit = 3)
      d = answer.digit
      l = max_digit - Math.log10(answer).floor
      if d.zero?
        ['', answer.to_i, '%d']
      elsif d <= l
        ['小数で', answer, "%.#{d}f"]
      else
        [", 小数第#{l + 1}位を四捨五入して小数第#{l}位まで", answer.round(l), "%.#{l}f"]
      end
    end

    def quiz(str, prov = '')
      format(
        "%s\n\n[[ref]]は, %d人の%sの結果を%sにまとめたものである。%sを%s求めよ。",
        @figure,
        @size,
        @label,
        @figure_name,
        str,
        prov
      )
    end

    def blank(str, post = '')
      format(
        "%s\n\n次の[[blank]]にあてはまる数を答えよ。\n\n[[ref]]は, %d人の%sの結果を%sにまとめたものである。%sは, 全体の人数の[[blank]]%sである。",
        @figure,
        @size,
        @label,
        @figure_name,
        str,
        post
      )
    end

    def data_transform(data, units)
      data = data.map(&:round)
      min, max = data.minmax
      interval = (max - min) / (1 + Math.log2(data.size).round)
      interval += 1 if interval.odd?
      if interval.odd?
        p interval
        exit
      end
      dmin = min / 2 * 2

      DataTable.new(data, interval: interval, min: dmin, unit: units)
    end
  end
end
