
class Filter
  def let_pass?(ele)
    warn 'not implemented'
    false
  end

  def filter(arr)
    arr.filter do |ele|
      let_pass?(ele)
    end
  end
end
