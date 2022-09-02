module Olivine::Generator::Probability
  class NumberOfCases
    COMPARISONS = [
      ['以上', :>=],
      ['以下', :<=],
      ['未満', :<],
    ]

    MULTIPLES = [
      ['素数', :prime?],
      ['偶数', :even?],
      ['奇数', :odd?],
      ['3の倍数', :multiple?, 3],
      ['4の倍数', :multiple?, 4],
      ['6の倍数', :multiple?, 6]
    ]

    CALCULATION = [
      [
        '$\\dfrac{a+b}{2}$の値が整数となる',
        proc { |a, b| (a + b).quo(2).zahlen? }
      ],
      [
        '$\\sqrt{ab}$の値が整数となる',
        proc { |a, b| (a * b).square? }
      ],
      [
        '$\\dfrac{a+b}{2}$または$\\sqrt{ab}$の値のうち, 少なくとも一つが整数となる',
        proc { |a, b| (a + b).square? || (a * b).quo(2).zahlen? }
      ],
      [
        '$\\dfrac{a+b}{2}$および$\\sqrt{ab}$の値が, どちらも整数となる',
        proc { |a, b| (a + b).square? && (a * b).quo(2).zahlen? }
      ],
      [
        '$\\sqrt{a+b}$の値が整数となる',
        proc { |a, b| (a + b).square? }
      ],
      [
        '$\\sqrt{a+2b}$の値が整数となる',
        proc { |a, b| (a + 2 * b).square? }
      ],
      [
        '$\\sqrt{2ab}$の値が整数となる',
        proc { |a, b| (2 * a * b).square? }
      ],
      [
        '$a<b$となる',
        proc { |a, b| a < b }
      ],
      [
        '$a\leqq b$となる',
        proc { |a, b| a <= b }
      ]
    ]
  end
end
