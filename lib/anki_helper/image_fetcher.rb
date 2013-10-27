require 'google_image_api'
# require 'ap'

class ImageFetcher
  class << self
    USER_AGENT = 'Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36' +
      ' (KHTML, like Gecko) Chrome/28.0.1500.89'
    def query_image_url(word)
      begin
        GoogleImageApi::Client.new.find('definition ' + word,
                                        :rsz => 1,
                                        :safe => :moderate,
                                        :order_by => :relevance,
                                        :imgsz => :medium,
                                        :as_filetype => 'jpg')
          .images.first['unescapedUrl'].to_s
      rescue NoMethodError
        sleep 5; retry
      end
    end

    def save_image(url, dir, filename)
      require 'open-uri'
      content = open(url).read
      File.open(File.join(dir, filename), 'w') do |f|
        f.write(content)
      end
      return filename
    end
  end

  def initialize(save_dir, prefix = nil)
    @save_dir = save_dir
    @filename_prefix = prefix || ''
  end

  def escape_word(word)
    word.gsub(/\s+/, '_')
      .gsub(/\./, '_')
  end
  def get_filename(word)
    @filename_prefix + escape_word(word) + '.jpg'
  end

  def fetch_and_save(word)
    filename = get_filename(word)
    filepath = File.join(@save_dir, filename)
    return filename if File.exist? filepath and File.size(filepath) > 0

    save(query(word), word)
  end
  def fetch_and_save_async(word)
    Thread.new { fetch_and_save }
    get_filename(word)
  end

  def query(word)
    self.class.query_image_url(word)
  end
  def save(url, word)
    self.class.save_image(url, @save_dir, get_filename(word))
  end

end

