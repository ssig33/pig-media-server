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
      array.each_with_index{|x,i|
        next unless File.exist?(x)
        next if File::ftype(x) == 'directory'
        flag = false
        $config['exclude_path'].each{|e| flag = true if x =~ /#{e.sub(/\//, '\/')}/ } if $config['exclude_path'].class.to_s == 'Array'
        next if flag
        Pig.find_or_create_by_path x
        puts "Crawl #{i+1} / #{array.count}"
      }
    end
  end
end
