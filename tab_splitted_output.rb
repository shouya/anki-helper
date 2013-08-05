
require_relative 'output'

class TabSplittedOutput < Output
  attr_accessor :fields, :entries
  def initialize(fields = [], entries = [])
    @fields = fields
    @entries = entries
  end


  def render_record(entry)
    @fields.map do |fld|
      content = nil

      content = case fld
                when Array  then
                  entry.send(fld.detect { |x| entry.respond_to? x }).to_s
                when Symbol then entry.send(fld).to_s
                when Proc   then fld.call(entry)
                else ''
                end

      content.tap(&:chomp!).tap(&:strip!)
      content = "&nbsp;" if content.empty?
      content.gsub!("\t", '&#09;')
      content.gsub!(/\n/, '<br />')
      content
    end.join("\t")
  end

  def render_all
    entries.map do |ent|
      render_record(ent) + "\n"
    end.join
  end

end
