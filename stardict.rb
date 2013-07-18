

require_relative 'dict'
require_relative 'entry'

require 'stardict'
StarDictLib = StarDict

Object.send :remove_const, :StarDict

class StarDict < Dict
  def initialize(dict_name)
    pwd = Dir.pwd
    Dir.chdir(File.join(ENV['HOME'], 'backup/usefuldict'))
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
    entry.word = word
    entry.syllables = nil
    entry.pronunciation = nil
    entry.explanation = raw
    entry.dict = self.name
    entry
  end
end

