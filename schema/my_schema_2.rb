
require_relative '../lib/anki_helper/anki_helper'
require 'threadpool'

dict_fallback_priority = [LazyWorm].map(&:new)
OUTFILE_PREFIX = 'out-'

# get word list from stdin
word_list = $stdin.read.chomp.each_line.map(&:chomp).map(&:strip)
word_list.delete('')


# set up image fetcher
img_fetchr = ImageFetcher.new('/home/shou/Pictures/vocabs')

pool = ThreadPool.new(30)

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
  result.image = img_fetchr.get_filename(word)
  pool.process {
    puts 'downloaing image for ' + word
    img_fetchr.fetch_and_save(word)
  }
  (query_results[result.dict] ||= []) << result
end
pool.join


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
    back
  end
  out.fields << lambda do |ent|
    '<img src="' + ent.image.to_s + '">'
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


puts 'done.'






