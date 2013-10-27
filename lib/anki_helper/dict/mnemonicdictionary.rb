require 'nokogiri'
require 'open-uri'
require_relative '../entry'

QUERY_URI = 'http://mnemonicdictionary.com/?word=%s'

class MnemonicDictionary
  def initialize
  end

  def name
    'mnemonicdictionary'
  end

  def query_webpage(word)
  end

  def query_word(word)
    entry = Entry.new
    mem_aids = Nokogiri::HTML(open(QUERY_URI % URI.encode(word)))
      .css('#home-middle-content').css('p:contains("Memory Aids")', Class.new do

                                       end)
    p mem_aids
    entry
  end
end


if __FILE__ == $0
  MnemonicDictionary.new.query_word('obdurate')
end
