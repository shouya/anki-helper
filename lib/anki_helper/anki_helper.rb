
require_relative 'entry'

def config
  require 'yaml'
  @config ||= YAML.load_file(File.join(File.dirname(__FILE__),
                                       '../../config.yml'))
  @config
end

%w[dict filter output].each do |component|
  Dir.glob(File.join(File.dirname(__FILE__), component) + '/*.rb').each {|x| require x }
end




