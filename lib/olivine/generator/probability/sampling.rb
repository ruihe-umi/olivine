module Olivine::Generator::Probability
  class Sampling < Base
    set_code 200
    set_label '標本調査'

    

    THINGS = {
      marked: [
        'ボール',
        %w[白い碁石 碁石],
        %w[黒い碁石 碁石],
        %w[白いカード カード 枚],
        %w[赤いカード カード 枚],
        %w[青いコイン コイン 枚],
        %w[緑色のコイン コイン 枚],
        '乾電池',
        'クリップ'
      ],
      added: [
        %w[ボール 白い 赤い],
        %w[碁石 白い 黒い],
        %w[碁石 黒い 白い],
        %w[カード 白い 赤い 枚],
        %w[カード 白い 青い 枚],
        %w[コイン 青い 黒い 枚],
        %w[コイン 緑色の 黒い 枚],
        %w[コイン 黒い 緑色の 枚],
        %w[コイン 黒い 青い 枚]
      ]
    }

    FORMAT1 = "次の[[blank]]にあてはまる数を求めよ。\n\n袋の中にボールがたくさん入っている。この袋から%d個のボールを取り出し, 全てに印をつけて袋に戻す。よく混ぜてから再び%d個のボールを取り出して印のついたボールの個数を数えたところ, その個数は%d個であった。このとき, 袋の中に入っているボールの個数はおよそ[[blank]]個と推定できる。"

    FORMAT2 = "次の[[blank]]にあてはまる数を求めよ。\n\n袋の中に白いボールがたくさん入っている。この袋に%d個の赤いボールを入れてよく混ぜる。その後, %d個のボールを取り出して赤いボールの個数を数えたところ, その個数は%d個であった。このとき, 袋の中に入っている白いボールの個数はおよそ[[blank]]個と推定できる。"

    FORMAT3 = "次の[[blank]]にあてはまる数を求めよ。\n\n袋の中に白いボールと赤いボールがたくさん入っている。袋の中から%d個のボールを取り出して赤いボールの個数を数えたところ, その個数は%d個であった。袋の中に入っている全てのボールの個数が%d個であるとき, そのうちの赤いボールの個数はおよそ[[blank]]個と推定できる。"

    def expression(&block)
      populate do |pop|
        max = [pop / 2, 1000].min
        50.step(max, 10) do |n|
          r = n.quo(pop)
          win = n * r
          mark(pop, n, win, &block) if win.zahlen? && confident?(r, n)
        end

        max = [pop / 10, 1000].min
        pop
          .divisors
          .select { |e| e.multiple?(10) && e.between?(100, max) }
          .each do |n|
          r = n.quo(pop + n)
          m = r.denominator
          m += m until confident?(r, m)
          add(pop, n, m, m * r, &block)
        end

        max = pop / 50
        pop
          .divisors
          .select { |e| e.between?(1, max) }
          .each do |m|
          r = m.quo(pop)
          min = (1 - r) * 4 * r / [0.1, r].min**2
          n = min.ceil / 10 * 10
          while pop / 10 > n
            win = n * r
            if win.zahlen?
              sample(pop, n, win, m, &block)
              break
            end
            n += 10
          end
        end
      end
    end

    def mark(pop, n, win)
      quiz = format(FORMAT1, n, n, win)
      THINGS[:marked]
        .each do |first, other, counter|
        other ||= first
        counter ||= '個'
        yield quiz.sub('ボール', first).gsub('ボール', other).gsub('個', counter), pop
      end
    end

    def add(pop, n, m, win)
      quiz = format(FORMAT2, n, m, win)
      THINGS[:added]
        .each do |thing, genuine, dummy, counter|
        counter ||= '個'
        yield quiz.gsub('ボール', thing).gsub('白い', genuine).gsub('赤い', dummy).gsub('個', counter), pop
      end
    end

    def sample(pop, n, win, m)
      quiz = format(FORMAT3, n, win, pop)
      THINGS[:added]
        .each do |thing, genuine, dummy, counter|
        counter ||= '個'
        yield quiz
          .gsub('ボール', thing)
          .gsub('白い', genuine)
          .gsub('赤い', dummy)
          .gsub('個', counter),
              m
      end
    end

    def confident?(p, n)
      4 * p * (1 - p) <= [p, 0.05].min**2 * n
    end

    def populate(&block)
      100.step(by: 10, to: 990, &block)
      1000.step(by: 100, to: 10_000, &block)
    end
  end
end
