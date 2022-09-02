class Vector # :nodoc:
  # ベクトルを回転させる
  # ----------
  # SVGはy軸が上下逆なので、 [c,-s][s,c]*selfだと
  # 思った通りの出力を得られない
  def rotate(rad)
    Matrix[
      [Math.cos(rad), Math.sin(rad)],
      [-Math.sin(rad), Math.cos(rad)]
    ] * self
  end

  def unit
    self / r
  end

  def arg
    arg = Math.atan2(-self[1], self[0])
    arg.negative? ? 2 * Math::PI + arg : arg
  end

  def join(sep = ' ')
    to_a.join(sep)
  end

  def times(v)
    raise ArgumentError, 'Dimention mismatch' unless size == v.size
    element(0) * v[1] - element(1) * v[0]
  end
end
