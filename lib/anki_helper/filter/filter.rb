
class Filter
  def let_pass?(ele)
    warn 'not implemented'
    false
  end

  def filter(arr)
    arr.select do |ele|
      let_pass?(ele)
    end
  end
end
