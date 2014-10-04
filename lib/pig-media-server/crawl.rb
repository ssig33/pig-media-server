require 'pig-media-server'
require 'pig-media-server/model/pig'


module PigMediaServer
  class Crawl
    def all
      $config = Pit.get("Pig Media Server")
      if ARGV[1]
        array = Dir.glob("#{ARGV[1]}/**/*")
      else
        array = Dir.glob("#{$config['path']}/**/*").sort
      end
      array.each.with_index(1){|x,i|
        next unless File.exist?(x)
        next if File::ftype(x) == 'directory'
        next if $config['exclude_path'].class == Array && $config['exclude_path'].find{|e| x =~ /#{e.sub(/\//, '\/')}/ }
        Pig.find_or_create_by_path x
        puts "Crawl #{i} / #{array.count}" if i % 100 == 0 or i ==array.count
      }
    end
  end
end
