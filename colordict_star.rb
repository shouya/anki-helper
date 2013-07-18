
require_relative 'filter'

STAR_PREFIX = "\xC2\xA1\xC3\x9A ".force_encoding('utf-8')

class ColorDictStarFilter < Filter
  def let_pass?(ele)
    ele.star_with? STAR_PREFIX
  end
end
