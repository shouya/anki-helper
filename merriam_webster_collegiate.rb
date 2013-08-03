require_relative 'stardict'

class MerriamWebsterCollegiate < StarDict
  def initialize
    super('mwc')
  end

  def name
    'mw_collegiate'
  end

  def query_word(word)
    entry = super
    entry.explanation.gsub!("\xE2\x80\xA2", '&bull;')
    entry
  end
end

if __FILE__ == $0
  require 'ap'
  dict = MerriamWebsterCollegiate.new
  rst = dict.query_word('hideous')
  ap rst
  puts rst.explanation
end

