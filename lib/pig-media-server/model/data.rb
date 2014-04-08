#coding:utf-8
require 'fileutils'
require 'digest/md5'
require 'pig-media-server/model/migrate'

$config = $config || Pit.get("Pig Media Server")


class AppData
  def self.find key
    key = Digest::MD5.hexdigest(key)
    parse(Groonga['Datas'][key].body)
  rescue
    nil
  end

  def self.set key, value
    g_key = Digest::MD5.hexdigest(key)
    Groonga['Datas'].add g_key
    Groonga['Datas'][g_key].body = value.to_json
    Groonga['Datas'][g_key].original_key = key
  end

  def self.all
    Groonga['Datas'].select.to_a.map{|x|
      {key: x.original_key, value: parse(x.body)}
    }
  end

  def self.parse val
    case val
    when 'true'
      true
    when 'false'
      false
    else
      JSON.parse val
    end
  rescue
    if val.class == String
      val.gsub(/^"|"$/, '')
    else
      val
    end
  end
end

class Stars
  def self.list user
    Pig.find Groonga['Stars'].select{|x|
      x._key =~ user
    }.to_a.map{|x| x._key.split('/').last}
  end

  def self.star? user, key
    key =user+'/'+key
    !!Groonga['Stars'][key]
  rescue
    false
  end

  def self.star user, key
    key =user+'/'+key
    Groonga['Stars'].add key
  end

  def self.unstar user, key
    key =user+'/'+key
    Groonga['Stars'].delete key
  end
end

class Recents
  def self.list user
    hash = {}
    Groonga['Recents'].select{|x|
      x._key =~ user
    }.to_a.map{|x| x._key.split("/").last}.each{|x|
      hash["movie/#{x}"] = {}
    }
    hash
  end

  def self.recent? user, key
    key =user+'/'+key
    !!Groonga['Recents'][key]
  rescue
    nil
  end

  def self.recent user, key
    key =user+'/'+key
    Groonga['Recents'].add key
  end
end

Dir.glob($config['user_data_path']+"/**/*.json").sort.each{|x|
  user = x.split("/").last.split(".json").first
  JSON.parse(open(x).read).map{|t| t}.select{|a| a.last.class != Array and a.last.class != Hash}.each{|ary|
    AppData.set("user_data/#{user}/#{ary.first}", ary.last)
  }
}
