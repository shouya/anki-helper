#!/bin/ruby
# Stardict library for ruby.
#
# Manipulates stardict dictionaries.
#
# NOTE: see pystardict.py and stardict doc in
# the source's tarball
#
# Author: Abdelrahman ghanem <abom.jdev@jmail.com>
#
# www.programming-fr34ks.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
require 'rubygems'
require 'zlib'
require 'stringio'
include Zlib
$VERSION='0.1.1'

class StarDict
  #Initialize a new stardict object, prefix
  #is the name of stardict files without extensions.
  #
  #example:
  #
  #     Dir.chdir(dict_dir)
  #     stardict=StarDict.new('lang_to_lang_dict') #without any extension.
  #     #you can also access dictionary options (.ifo file data) by:
  #
  #     puts stardict.bookname #prints the book/dict name
  def initialize(prefix)
    @prefix=prefix
    @info=info_data
    @idx=idx_data
    @dict=dict_data
    define_options
    parse
  end
  #Returns a hash of wordlist {word=>translation},
  #also similar words had its translation merged.
  def wordlist
    @wordlist
  end
  #Returns true if exists, otherwise false.
  def word_exists?(word)
    @wordlist.key?(word)
  end
  #Returns true if exists, otherwise false.
  def trans_exists?(trans)
    @wordlist.values.include?(trans)
  end
  #Returns the translaton of 'word'.
  def find_by_word(word)
    @wordlist[word] if word_exists?(word)
  end
  #Returns the word of 'trans'.
  def find_by_trans(trans)
    @wordlist.invert[trans] if trans_exists?(trans)
  end
  #Performs a search in the whole dictionary, returns a hash of results.
  def search(keyword)
    re=@wordlist.
    select do |k,v|
      k.include?(keyword)|
      v.include?(keyword)
    end
    Hash[*re.flatten!]
  end
  #Wordlist count.
  def wordlist_count
    @wordlist.length
  end

  private

  def info_data
    data=get_data("#{@prefix}.ifo",nil)
    opts=data.scan(/(.*)=(.*)/)
    Hash[*opts.flatten]
  end

  def idx_data
    get_data("#{@prefix}.idx","#{@prefix}.idx.gz")
  end

  def dict_data
    StringIO.new(get_data("#{@prefix}.dict","#{@prefix}.dict.dz"))
  end

  def define_options
    @info.each do |k,v|
      self.class.send(:define_method, k) { v }
    end
  end

  def parse
    entries=@idx.scan(/([\d\D]+?\x00[\d\D]{8})/)

    if entries.length!=@info['wordcount'].to_i
      raise 'word count is not correct'
    end

    @wordlist={}

    entries.each do |entry|
      entry=entry.first.to_s
      t_pos=entry.index("\0")+1
      re=entry.unpack("A#{t_pos}NN")
      @dict.seek(re[1])
      word,trans=re[0],@dict.read(re[2])
      #for duplicated key:
      #append for exiting one
      #if it exisis
      if @wordlist.key?(word)
	@wordlist[word]+="\n#{trans}"
      else
	@wordlist[word]=trans
      end
    end;@wordlist
  end

  def get_data(file,gz)
    begin
      File.open(file,'rb'){|f|f.read}
    rescue
      begin
        GzipReader.open(gz){|f|f.read}
      rescue
	raise IOError, "can not open '#{file}' or gz '#{gz}'"
      end
    end
  end

end
