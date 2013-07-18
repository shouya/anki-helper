
$: << '.'

require 'colordict_star'
require 'increment'

require 'collins_cobuild'
require 'wordnet'
require 'lazyworm'

dict_fallback_priority = [CollinsCobuild, WordNet, LazyWorm].map(&:new)
OUTFILE_PREFIX = 'out-'



# get word list from stdin
word_list = gets.each_line.map(&:chomp).map(&:strip)

# filter star-prefixed words (marked word in colordict)
word_list = colorColorDictStarFilter.new.filter(word_list)

# filter non-former-proceeded words
inc_fltr = IncrementFilter.new
word_list = inc_fltr.filter(word_list)

# key: dict_name, val: an Array of entries
query_results = Hash.new { Array.new }

# query the dicts
word_list.each_with_index do |word, idx|
  print "(#{idx+1}/#{word_list.length}) #{word}\t"
  dict = dict_fallback_priority.detect {|d| d.word_exists? word }
  (query_results[:missing] << word; puts '[missing]'; next) if dict.nil?

  puts "...\t#{dict.name.to_s}"

  result = dict.query_word(word)
  query_results[result.dict] << result
end

# produce the result
query_results.each do |dict, entries|
  File.open(OUTFILE_PREFIX + dict.to_s + '.txt', 'w') do |f|
    entries.each do |ent|
      f.print ent.word
      f.print "\t"
      front = ent.syllables || ent.word
      front += ' ' + ent.pronunciation unless ent.pronunciation.nil?
      f.print "\t"
      f.print ent.explanation
      f.puts
    end
  end
end

inc_fltr.produce_increment_file





