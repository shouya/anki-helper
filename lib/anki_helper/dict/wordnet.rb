
require_relative 'stardict'

class WordNet < StarDict
  def name
    'wordnet'
  end
  def initialize
    super('dictd_www.dict.org_wn')
  end
end
