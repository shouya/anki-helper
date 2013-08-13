
require_relative 'entry'
require_relative '../../config'

%w[dict filter output].each do |component|
  Dir.glob(File.join(File.dirname(__FILE__), component) + '/*.rb').each {|x| require x }
end




