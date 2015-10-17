require 'pig-media-server'
require 'pig-media-server/model/pig'
require 'mechanize'


module PigMediaServer
  class Crawl

    def recommend
      users = Groonga['Datas'].select.to_a.map{|x| x.original_key}.select{|x| x =~ /user_data/}.map{|x| x.split("/")[1]}.uniq

      users.each do |user|
        keys = []
        animetick = Groonga['Datas'].select{|x| x.original_key == "user_data/#{user}/animetick" }.first
        if animetick
          animetick = animetick.body.gsub('"', '')
          alice = Mechanize.new
          page = alice.get("http://animetick.net/users/#{animetick}")
          titles = page.root.xpath('//*[@id="body"]/div[3]/ul/li/div[2]').map{|x| x.inner_text}.map{|x|
            x.gsub(/\n\ +/, '')
          }
          titles.each{|title|
            title = title.split('').map{|x|
              if x =~ /\p{Han}|\p{Hiragana}|\p{Katakana}|[0-9a-zA-Z]/
                x
              else
                ' '
              end

            }.join('').sub(/\ +$/, '')
            Groonga['Files'].select(Sewell.generate(title, ['path'])).select{|x| x.path =~ '.mp4'}.to_a.each{|record|
              next if record.mtime < Time.now.to_i-86400*30*5
              keys << record
            }
          }
          keys = keys.sort_by{|x| -x.mtime}.map{|x| x._key}
          FileUtils.mkdir_p "#{$config['user_data_path']}/recommend"
          open("#{$config['user_data_path']}/recommend/#{user}", 'w'){|f| f.puts keys.join("\n")}
        end
      end
    end

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
      self.recommend
    end
  end
end
