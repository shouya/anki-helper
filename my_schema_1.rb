
%w[colordict_star increment collins_cobuild wordnet lazyworm].each do |x|
  Kernel.require_relative x
end

dict_fallback_priority = [CollinsCobuild, WordNet, LazyWorm].map(&:new)
OUTFILE_PREFIX = 'out-'


# get word list from stdin
word_list = $stdin.read.chomp.each_line.map(&:chomp).map(&:strip)
word_list.delete('')

# filter star-prefixed words (marked word in colordict)
word_list = ColorDictStarFilter.new.filter(word_list)

# filter non-former-proceeded words
inc_fltr = IncrementFilter.new
word_list = inc_fltr.filter(word_list)

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

unless missing.empty?
  puts 'entries missing:'
  missing.each do |x|
    puts "\t- " + x.to_s
  end
end

puts 'producing the increment history.'
inc_fltr.produce_increment_file

puts 'done.'






