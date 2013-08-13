
require_relative 'stardict'

class LazyWorm < StarDict
  def initialize
    super('lazyworm-ec-big5')
  end

  def name
    'lazyworm'
  end

  def query_word(word)
    entry = super

    entry.pronunciation = entry.explanation[/\[(.*?)\]/, 1]
    entry.explanation.gsub!(/\[(.*?)\]\<br \/\>/, '')

    entry
  end
end
