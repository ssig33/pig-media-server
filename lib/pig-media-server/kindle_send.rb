require 'mail'
require 'pony'
require 'pig-media-server'
require 'pig-media-server/model/pig'

module PigMediaServer
  class KindleSend
    def run
      pit_config = Pit.get 'Pig Media Server'
      while true
        begin
          GC.start
          from_hash = Hash[*Dir.glob("#{pit_config['user_data_path']}/*.json").map{|t| JSON.parse open(t).read}.select{|t| t['kindle_to'] and t['kindle_from']}.map{|t| [t['kindle_to'], t['kindle_from']]}.select{|t| t.first != '' and t.last != ''}.flatten]
          Dir.glob("#{pit_config['user_data_path']}/kindle/queue/*").each{|x|
            begin
              queue = x.split('/').last
              key = queue.split('_').first
              user_id = queue.split('_').last
              config = JSON.parse open("#{pit_config['user_data_path']}/#{user_id}.json").read
              p [key, user_id, config['kindle_to'], config['kindle_from']]

              pig = Pig.find key
              puts 'start send' 
              from_hash.each{|to, from|
                p [to, from]
                Pony.mail({
                  :to => to,
                  from: from,
                  subject: '',
                  body: '',
                  attachments: {"#{key}.mobi" => File.read(pig.record.path)},
                  :via => :smtp,
                  :via_options => pit_config['smtp'].dup
                })
              }
            rescue =>e
              p e
              p e.backtrace
            end
            FileUtils.cd '/home/ssig33/dev/pig'
            FileUtils.rm x
            puts 'end '+x
          }
        rescue => e
          p e
          p e.backtrace
        end
        sleep 1
      end
    end
  end
end
