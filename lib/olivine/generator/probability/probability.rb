module Olivine::Generator::Probability
  class Probability < NumberOfCases
    set_code 110
    set_label '数学的確率'

    

    def initialize
      @queue = []
      @prepend = ""
      @format = "%s確率を求めよ。"
      @prob = true
      @fig = ''
    end

    def expression(&block)
      add(
        op: :simple,
        str: '1～6の目が出る大小1つずつのさいころを同時に1回投げるとき, 出る目の数%sになる'
      )

      add(
        op: :digit,
        str: '1～6の目の出る大小1つずつのさいころを同時に1回投げ, 大きなさいころの出る目の数を十の位, 小さなさいころの出る目の数を一の位とする2けたの整数をつくるとき, この2けたの整数が%sになる'
      )

      add(
        op: :calculate,
        str: "1～6の目の出る大小1つずつのさいころを同時に1回投げる。大きなさいころの出た目の数を$a$, 小さなさいころの出た目の数を$b$とするとき, %s"
      )

      @pop = {
        first: (0..1),
        size: (4..5),
        convert: [
          :itself,
          proc { |e| e * 2 }
        ],
        str: '[[ref]]のように, %sの数字が1つずつ書かれたカードが%d枚ある。'
      }
      @fig_method = :cards
      add(
        choise: :combination,
        op: :simple,
        str: 'この[[size]]枚のカードから同時に2枚のカードを取り出すとき, 取り出した2枚のカードに書かれている数%sである'
      )

      add(
        choise: :permutation,
        op: :digit,
        str: 'この[[size]]枚のカードから2枚のカードを選び, 2けたの整数をつくるとき, この2けたの整数が%sになる'
      )

      add(
        choise: :permutation,
        op: :calculate,
        str: 'この[[size]]枚のカードをよく混ぜてから, 続けて2枚のカードをひき, 1枚目にひいたカードに書いてある数を$a$, 2枚目にひいたカードに書いてある数を$b$とするとき, %s'
      )

      rep = 'この[[size]]枚のカードをよく混ぜてから1枚ひき, 書いてある数を記録して戻す。再びよく混ぜてから1枚ひき, 書いてある数を記録する。'
      add(
        op: :digit,
        str: rep + '1回目に記録した数を十の位, 2回目に記録した数を一の位とする2けたの整数をつくるとき, この2けたの整数が%sになる'
      )

      add(
        op: :calculate,
        str: rep + '1回目に記録した数を$a$, 2回目に記録した数を$b$とするとき, %s'
      )

      @pop[:str] = '[[ref]]のように, 袋の中に%sが1つずつ書かれたボールが%d個入っている。'
      @fig_method = :balls
      add(
        choise: :combination,
        op: :simple,
        str: 'この袋から同時に2個のボールを取り出すとき, 取り出した2個のボールに書かれている数%sである'
      )

      add(
        choise: :permutation,
        op: :digit,
        str: 'この袋から続けて2個のボールを取り出し, 1個目に取り出したボールに書いてある数を十の位, 2個目に取り出したボールに書いてある数を一の位とする2けたの整数をつくるとき, この2けたの整数が%sになる'
      )

      add(
        choise: :permutation,
        op: :calculate,
        str: 'この袋から続けて2個のボールを取り出し, 1個目に取り出したボールに書いてある数を$a$, 2個目に取り出したボールに書いてある数を$b$とする。%s'
      )

      rep = 'この袋から1個のボールを取り出し, 取り出したボールに書いてある数を記録して戻す。再び袋から1個のボールを取り出し, 取り出したボールに書いてある数を記録する。'
      add(
        op: :digit,
        str: rep + '1回目に記録した数を十の位, 2回目に記録した数を一の位とする2けたの整数をつくるとき, この2けたの整数が%sになる'
      )

      add(
        op: :calculate,
        str: rep + '1回目に記録した数を$a$, 2回目に記録した数を$b$とするとき, %s'
      )

      quiz(&block)
    end

    def test(val)
      size = @whole.size
      size > 1 && val.between?(1, size - 1) && val.gcd(size) > 1
    end
  end
end

require_relative 'number_of_cases/consts'
require_relative 'number_of_cases/core'
require_relative 'number_of_cases/operation'
