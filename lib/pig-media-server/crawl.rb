require 'pig-media-server'
require 'pig-media-server/model/pig'

module PigMediaServer
  class Crawl
    def all
      config = Pit.get("Pig Media Server")
      array = Dir.glob("#{config['path']}/**/*").sort
      array.each_with_index{|x,i|
        next if File::ftype(x) == 'directory'
        flag = false
        config['exclude_path'].each{|e| flag = true if x =~ /#{e.sub(/\//, '\/')}/ } if config['exclude_path'].class.to_s == 'Array'
        next if flag
        Pig.find_or_create_by_path x
        puts "Crawl #{i+1} / #{array.count}"
      }
      all = Pig.all
      all.each_with_index{|x,i|
        puts "Check #{i+1} / #{all.count}"
      }
    end
  end
end
