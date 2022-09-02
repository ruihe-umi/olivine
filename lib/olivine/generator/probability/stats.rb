module Olivine::Generator::Probability
  module Stats
    PHYSICALS = [
      {
        label: '握力',
        unit: 'kg',
        avg: 28.80,
        sd: 7.20
      },
      {
        label: '握力',
        unit: 'kg',
        avg: 23.43,
        sd: 4.66
      },
      {
        label: '上体起こし',
        unit: '回',
        avg: 25.99,
        sd: 6.19
      },
      {
        label: '上体起こし',
        unit: '回',
        avg: 22.32,
        sd: 5.82
      },
      {
        label: '長座体前屈',
        unit: 'cm',
        avg: 43.67,
        sd: 10.87
      },
      {
        label: '長座体前屈',
        unit: 'cm',
        avg: 46.20,
        sd: 10.19
      },
      {
        label: '反復横とび',
        unit: '点',
        avg: 51.19,
        sd: 8.47
      },
      {
        label: '反復横とび',
        unit: '点',
        avg: 46.25,
        sd: 7.00
      },
      # {
      #   label: '持久走',
      #   unit: '秒',
      #   avg: 406.38,
      #   sd: 70.52
      # },
      # {
      #   label: '持久走',
      #   unit: '秒',
      #   avg: 297.62,
      #   sd: 46.06
      # },
      {
        label: 'シャトルラン',
        unit: '回',
        avg: 79.88,
        sd: 25.33
      },
      {
        label: 'シャトルラン',
        unit: '回',
        avg: 54.24,
        sd: 19.86
      },
      # {
      #   label: '50m走',
      #   unit: '秒',
      #   avg: 8.88,
      #   sd: 0.84
      # },
      # {
      #   label: '50m走',
      #   unit: '秒',
      #   avg: 8.01,
      #   sd: 0.91
      # },
      {
        label: '立ち幅とび',
        unit: 'cm',
        avg: 196.36,
        sd: 29.45
      },
      {
        label: '立ち幅とび',
        unit: 'cm',
        avg: 168.15,
        sd: 25.20
      },
      {
        label: 'ハンドボール投げ',
        unit: 'm',
        avg: 20.31,
        sd: 5.91
      },
      {
        label: 'ハンドボール投げ',
        unit: 'm',
        avg: 12.72,
        sd: 4.20
      },
    ]

    def self.random_data(method = :box_muller, **ops)
      public_send(method, **ops)
    end

    def self.box_muller(avg: 0, sd: 1, size: 30, min: nil, max: nil, seed: nil)
      result = []
      min ||= avg - 2 * sd
      max ||= avg + 2 * sd
      range = Range.new(min, max)
      seed.present? ? srand(seed) : srand()
      while result.size < size
        r = Math.sqrt(-2 * Math.log(rand)) * Math.sin(2 * Math::PI * rand)
        val = avg + sd * r
        result << val if range.cover?(val)
      end

      result
    end
  end
end
