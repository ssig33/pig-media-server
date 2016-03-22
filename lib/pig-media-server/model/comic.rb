require 'zipruby'
require 'rmagick'

class Comic
  attr_accessor :record, :config
  def initialize record
    self.record = record
    self.config = Pit.get "Pig Media Server"
  end
  def id; self.record._key;end
  def max_page; self.files.count; end
  def title; self.record.path.split("/").last;end
  def left
    data = "#{self.config['user_data_path']}/comic_#{self.record._key}.comic" 
    open(data, 'w'){|f| f.puts({left: false}.to_json)} unless File.exist? data
    JSON.parse(open(data).read)['left']
  end

  def info count
    m = self.image(count)
    x = m.columns
    y = m.rows
    {portlait: (x.to_f/y.to_f > 1.0)}
  end

  def page count
    m = self.image count
    case m.format
    when "JPEG"
      type = 'image/jpeg'
    when "PNG"
      type = 'image/png'
    end
    [m.to_blob, type]
  end

  def image count
    count = count.to_i-1
    count = 0 if count < 0
    file = nil
    name = self.files[count]
    Zip::Archive.open(self.record.path) do |as|
      as.each do |a|
        if a.name == name
          file = a.read
          break
        end
      end
    end
    Magick::Image.from_blob(file).first
  end

  def files
    ar = []
    Zip::Archive.open(self.record.path) do |as|
      as.each do |a|
        if a.name =~ /.png$/ or a.name =~ /.jpg$/ or a.name =~ /.PNG$/ or a.name =~ /.JPG$/ or a.name =~ /.jpeg$/ or a.name =~ /.JPEG$/
          ar << a.name
        end
      end
    end
    ar.sort
  end
end
