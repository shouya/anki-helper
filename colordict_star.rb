
require_relative 'filter'

STAR_PREFIX = "\xE2\x98\x85 ".force_encoding('utf-8')

class ColorDictStarFilter < Filter
  def let_pass?(ele)
    ele.start_with? STAR_PREFIX
  end
  def filter(arr)
    super.map {|x| x[STAR_PREFIX] = ''; x }
  end
end
