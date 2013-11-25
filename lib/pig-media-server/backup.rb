require 'pig-media-server/script'
require 'tmpdir'

module PigMediaServer
  class Backup
    def backup
      pit_config = Pit.get 'Pig Media Server'
      backup_path = pit_config['backup_path']
      Dir.mktmpdir do |tmpdir|
        FileUtils.cd tmpdir
        date = Date.today

        a = $f.select.to_a
        open("backup.json", "w"){|f|
          a.each_with_index{|x,i|
            f.puts [x._key, x.path, x.metadata, x.srt].to_json
            puts "#{i+1} / #{a.count}" if i%100 ==0
          }
        }
        open('groonga.schema', 'w'){|x| x.puts Groonga::Schema.dump}
        system "tar zcvf #{date}.tar.gz backup.json groonga.schema"
        FileUtils.mv "#{date}.tar.gz", backup_path
      end
    end
  end
end
