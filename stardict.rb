

require_relative 'dict'
require_relative 'entry'
require_relative 'config'

require_relative 'rbstardict'
StarDictLib = StarDict

Object.send :remove_const, :StarDict

class StarDict < Dict
  def initialize(dict_name)
    pwd = Dir.pwd
    Dir.chdir(STARDICT_DIR)
    @dict = StarDictLib.new(dict_name)
    Dir.chdir(pwd)
  end

  def word_exists?(word)
    word.tap(&:strip!).tap(&:downcase!)
    return false unless @dict.word_exists? word
    true
  end

  def query_word(word)
    word.tap(&:strip!).tap(&:downcase!)
    raise WordNotFoundException unless @dict.word_exists? word
    raw = @dict.find_by_word(word).chomp.strip.gsub(/\n/, '<br />')

    entry = Entry.new
    entry.word = word.gsub(/\t/, ' ')
    entry.syllables = nil
    entry.pronunciation = nil
    entry.explanation = raw.gsub(/\t/, ' ')
    entry.dict = self.name
    entry
  end
end

