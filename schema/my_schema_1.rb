
require_relative '../lib/anki_helper/anki_helper'

dict_fallback_priority = [CollinsCobuild, MerriamWebsterCollegiate,
                          WordNet, LazyWorm].map(&:new)
dict_lw = LazyWorm.new
OUTFILE_PREFIX = 'out-'


# get word list from stdin
word_list = $stdin.read.chomp.each_line.map(&:chomp).map(&:strip)
word_list.delete('')

# filter star-prefixed words (marked word in colordict)
word_list = ColorDictStarFilter.new.filter(word_list)

# filter non-former-proceeded words
inc_fltr = IncrementFilter.new

puts word_list.length
word_list = inc_fltr.filter(word_list)
puts word_list.length

word_list = DowncaseFilter.new.filter(word_list)

# key: dict_name, val: an Array of entries
query_results = Hash.new
missing = []

puts 'querying dictionaries.'
# query the dicts
word_list.each_with_index do |word, idx|
  print "(#{idx+1}/#{word_list.length}) #{word}\t"
  dict = dict_fallback_priority.detect {|d| d.word_exists? word }
  (missing << word; puts '[missing]'; next) if dict.nil?

  puts "...\t#{dict.name.to_s}"

  result = dict.query_word(word)
  (query_results[result.dict] ||= []) << result
end

# produce the result
puts 'producing the result.'


# output file
query_results.each do |dict, entries|
  out = TabSplittedOutput.new
  out.fields << :word
  out.fields << lambda do |ent|
    front = ent.syllables || ent.word
    front += ' ' + ent.pronunciation unless ent.pronunciation.nil?
    front
  end
  out.fields << lambda do |ent|
    back = ent.explanation.to_s
    (back += "\n" + dict_lw.query_word(ent.word).explanation) rescue WordNotFoundException

    back
  end
  #  out.fields << :explanation
  out.entries = entries

  File.open(OUTFILE_PREFIX + dict.to_s + '.txt', 'w') do |f|
    f.write(out.render_all)
  end
end

unless missing.empty?
  puts 'entries missing:'
  missing.each do |x|
    puts "\t- " + x.to_s
  end
end

puts 'producing the increment history.'
inc_fltr.produce_increment_file

puts 'done.'






