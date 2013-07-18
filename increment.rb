
require_relative 'filter'

class IncrementFilter < Filter
  def initialize(prefix = 'prev_')
    @prefix = prefix.to_s
    @words = Dir.glob(@prefix + '*')
      .sort {|a,b| File.ctime(b) <=> File.ctime(a) }
      .map { |x| File.read(x).each_line
        .map(&:chomp)
        .to_a
        .reject {|xx| xx =~ /^\#/ or xx =~ /^\s*$/} }
      .inject([], &:concat)
    @new_words = []
  end

  def let_pass?(ele)
    @new_words << ele
    not @words.include? ele
  end

  def produce_increment_file
    backup_filename = @prefix + Time.now.to_i.to_s + '.txt'
    @new_words.sort!
    open(backup_filename, 'w') do |f|
      @new_words.each do |word|
        f.puts word
      end
    end
  end
end
