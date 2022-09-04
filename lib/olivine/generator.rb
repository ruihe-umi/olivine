#
# 問題作成用のベースクラス。
# * 作成用の各クラスは、これを継承して*expression*メソッドを実装すること
#
module Olivine::Generator
  require_relative 'generator/utils.rb'

  class Base
    include Olivine::Generator::Utils
    # よく使う1ケタの非ゼロ整数 (-9...-1, 1...9)
    DIGIT = [
      -9, -8, -7, -6, -5, -4, -3, -2, -1,
      1, 2, 3, 4, 5, 6, 7, 8, 9
    ]

    # 問題と解答を作成するジェネレータメソッド。
    # 各単元ごとにexpressionメソッドを実装する。
    def generate
      return to_enum(:generate) unless block_given?

      expression do |quiz, answer|
        yield format_quiz(quiz), format_answer(answer)
      end
    end

    protected

    # 問題文を整形する。単元ごとにオーバーライドして使う。
    # 初期は "$_expr_$を計算せよ。"
    # _expr_ :: expression
    def format_quiz(expr)
      "$#{format_expression(expr)}$を計算せよ。"
    end

    # 解答を整形する。単元ごとにオーバーライドして使う。
    # 初期は "$_expr_$"
    # _expr_ :: expression
    def format_answer(expr)
      "$#{format_expression(expr)}$"
    end

    def format_expression(expr)
      expr.to_tex
          .gsub('**', '^')
          .gsub('*', '\\times')
          .gsub('/', '\\div')
          .gsub('+-', '-')
          .gsub(/(?<![\d.])1\s*(\(|[a-z]|\\(sqrt|dfrac|pi))/, '\1')
          .gsub(/(times|div)(\s*)(-(\d+|\\dfrac{.+?}{.+?})(\^\d)?)/) do
            "#{Regexp.last_match(1)}(#{Regexp.last_match(3)})"
          end
          .gsub(/\((.+?)\)/, '\left\lparen \1\right\rparen ')
    end

    # 問題コードを登録する
    # _code_ :: 5桁の整数値
    def self.set_code(code)
      int = code.to_i
      raise ArgumentError, 'Unit code must be 6-digit integer.' unless int.between?(100, 999)

      define_singleton_method(:code) do
        self.unit[1] * 1000 + int
      end
    end

    # 小単元名を登録する
    # _label_ :: 文字列
    def self.set_label(label)
      define_singleton_method(:label) do
        label
      end
    end

    def self.set_note(note)
      define_singleton_method(:note) do
        note
      end
    end

    def self.set_unit(label, code)
      define_singleton_method(:unit) do
        return label, code
      end
    end

  end
end

require_dir 'generator'
