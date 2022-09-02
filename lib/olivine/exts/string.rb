class String # :nodoc:
  def to_tex
    self
  end

  def to_math
    gsub(/[a-zA-Z]/) do |chr|
      int = chr.ord
      case int
      when (0x41..0x5a)
        (int + 0x1d3f3).chr(Encoding::UTF_8)
      when (0x61..0x7a)
        (int + 0x1d3ed).chr(Encoding::UTF_8)
      else
        chr
      end
    end
  end
end
