require 'pig-media-server'
require 'pig-media-server/model/pig'

module PigMediaServer
  class Aspect
    def run
      pit_config = Pit.get 'Pig Media Server'
      while true
        GC.start
        begin
          q = open("#{pit_config['user_data_path']}/rate/queue.txt").read.split("\n")
          q.each do |x|
            next if x == ''
            key = x.split(' ').first
            rate = x.split(' ').last
            pig = Pig.find key
            if rate == '16:9'
              system 'MP4Box', '-add', "#{pig.record.path}:par=1:1", '-new', "#{pig.record.path}.MP4"
              FileUtils.mv "#{pig.record.path}.MP4", pig.record.path
            end
          end
          open("#{pit_config['user_data_path']}/rate/queue.txt", 'w'){|x| x.puts ''}
        rescue => e
          p e
        end
        sleep 5
      end
    end
  end
end
