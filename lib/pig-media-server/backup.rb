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
            f.puts [x._key, x.path, x.metadata, x.srt, x.mtime, x.size].to_json
            puts "#{i+1} / #{a.count}" if i%100 ==0
          }
        }
        open('groonga.schema', 'w'){|x| x.puts Groonga::Schema.dump}
        system "tar zcvf #{date}.tar.gz backup.json groonga.schema"
        FileUtils.mv "#{date}.tar.gz", backup_path
      end
    end

    def restore_from path
      raise unless File.exist? path
      pit_config = Pit.get 'Pig Media Server'
      Dir.glob("#{pit_config['groonga']}/**/*").each{|x| FileUtils.rm x}
      Groonga::Database.create path: pit_config['groonga']+"/search"
      Dir.mktmpdir do |tmpdir|
        FileUtils.cd tmpdir
        FileUtils.cp path, "."
        system 'tar', 'xvf', Dir.glob("*.gz").first
        system 'ls'
        FileUtils.rm Dir.glob("*.gz").first 
        Groonga::Schema.restore(open('groonga.schema').read){|schema| schema.define }
        $f = Groonga['Files']
        json =open("backup.json").read.split("\n")
        json.each_with_index{|x,i|
          x = JSON.parse x
          $f.add(x[0])
          $f[x[0]].path = x[1]
          $f[x[0]].metadata = x[2]
          $f[x[0]].srt = x[3]
          $f[x[0]].mtime = x[4]
          $f[x[0]].size = x[5]
          puts "#{i+1} / #{json.count}" if i%100 == 0 or i+1 == json.count
        }
      end
      ary = $f.select.to_a

      lost = []

      ary.each_with_index{|x,i|
        if x.path.nil?
          $f.delete x._key
          next
        end
        puts "#{i+1} / #{ary.count}" if (i+1)%1000 == 0 or i+1 == ary.count
      }
      lost.sort.each{|x| puts x}
    end
  end
end
