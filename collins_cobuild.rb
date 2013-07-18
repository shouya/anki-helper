require_relative 'stardict'

class CollinsCobuild < StarDict
  def initialize
    super('Collins5')
  end

  def name
    'collins_cobuild'
  end

  def query_word(word)
    entry = super
    entry.syllables = entry.explanation[/\<b\>\xE2\x97\x86 (.*?)\<\/b\>/, 1]
    entry.pronunciation =
      entry.explanation[/\<FONT COLOR\=\"\#909090\"\>(.*?)\<\/FONT\>/, 1]
    entry
  end
end

