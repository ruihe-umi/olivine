# Olivine

[中学数学の練習プリント（小問集合）を作るWeb App](https://nettle-generator.herokuapp.com/)のための練習問題を作るモジュール。元々は一緒にしていたのを分離した。

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'olivine'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install olivine

## Usage

詳しい作りについては[Wep Appの解説ページ](https://nettle-generator.herokuapp.com/spec)にまとめたのでそちらを参考にされたい。バグレポートはGit経由で。

以下、今後の改良のための覚え書き

- exts以下に```Numeric```その他標準ライブラリの独自拡張が入っている。```Integer.prime_to?(other)```みたいなよく使うあると便利なやつを突っ込んだもの。競合に注意。
- SVGは **y軸が上下逆（正が下向き）**
- ```Generator::Base#generate```が全ての大元になるメソッド。ここから問と答えが生えてくるようにすればOK。

  で、その中身が
  ```ruby
  def generate
    return to_enum(:generate) unless block_given?
    expression do |quiz, answer|
      yield format_quiz(quiz), format_answer(answer)
    end
  end
  ```
  となっているので、この形になるように```def expression```して```yield```するなり```&block```するなりすればOK。ジェネレータの形になっているのは、元々herokuでPostgreSQLに一括挿入するにあたり[```activerecord-import```](https://github.com/zdennis/activerecord-import)を使おうとしていたのが、エラーを吐いて止まってしまうので、仕方なく一件一件```INSERT```するように変えたため。
- 本当はLaTeXでPDFを作成できるようにしたかったが、herokuにデプロイしたら300MB以上もくう上にいろいろなパッケージが足りなかったので諦めた。そのうち別のサーバに移す機会がやりたい。ただ、wrapfigureの問題があるのであまりきれいにプリントできないかもしれない。数式だけ（図表なし）ならなんとかなるかも。
- tikzを使うならSVGを書き換えるか、あるいは共用のILみたいなのを出力すべきかも。やろうと思ったがLaTeXを使わなくなったのでやめた。
- 枝問ありのやつも実装してみたい。でも本来のコンセプト（小問集合の練習）から外れすぎる？　やるならlong-olivineとかにして別立てかな？
- 全体的にクラスの分け方があんまりきれいじゃないかも。
