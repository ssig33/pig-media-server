require 'mail'
require 'pony'
require 'pig-media-server'
require 'pig-media-server/model/pig'
require 'pig-media-server/model/data'

module PigMediaServer
  class KindleSend
    def run
      pit_config = Pit.get 'Pig Media Server'
      100.times do 
        #begin
          GC.start
          a = AppData.all.select{|x| x[:value].class == String and x[:key] =~ /kindle/ and x[:value] =~ /@/}.sort{|a2,b| a2[:key] <=> b[:key]}
          froms = a.select{|x| x[:key] =~ /from/}
          tos = a.select{|x| x[:key] =~ /to/}
          from_data = {}
          tos.count.times{|i|
            from_data[tos[i][:value]] = froms[i][:value]
          }
          Dir.glob("#{pit_config['user_data_path']}/kindle/queue/*").each{|x|
            begin
              queue = x.split('/').last
              key = queue.split('_').first

              pig = Pig.find key
              puts 'start send: '  + pig.path
              from_data.each{|to, from|
                begin
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
                rescue
                end
              }
            rescue =>e
              p e
              p e.backtrace
            end
            FileUtils.cd '/home/ssig33/server'
            FileUtils.rm x
            puts 'end '+x
          }
        #rescue => e
        #  p e
        #  p e.backtrace
        #end
        sleep 10
      end
    end
  end
end
