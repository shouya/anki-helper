
require_relative 'filter'

class DowncaseFilter < Filter
  def let_pass?(*)
    true
  end
  def filter(arr)
    super.map {|x| x.downcase }
  end
end
