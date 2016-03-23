#coding:utf-8
require 'fileutils'
require 'digest/md5'
require 'pig-media-server/model/migrate'

require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
ActiveRecord::Base.logger = Logger.new(STDOUT)

tables =  ActiveRecord::Base.connection.tables

unless tables.index('app_datas')
  ActiveRecord::Migration.create_table :app_datas do |t|
    t.string :key
    t.string :original_key
    t.text :value
    t.timestamps null: false
  end
end

unless tables.index('stars')
  ActiveRecord::Migration.create_table :stars do |t|
    t.string :user_id
    t.string :key
    t.timestamps null: false
  end
end

unless tables.index('recents')
  ActiveRecord::Migration.create_table :recents do |t|
    t.string :user_id
    t.string :key
    t.timestamps null: false
  end
end

class AppData < ActiveRecord::Base
  def self.find key
    key = Digest::MD5.hexdigest(key)
    a = self.where(key: key).first
    if a
      a.parse
    else
      nil
    end
  end

  def self.set key, value
    a_key = Digest::MD5.hexdigest(key)
    a = self.find_or_create_by(key: a_key)
    a.value = value.to_json
    a.original_key = key
    a.save!
  end

  def self.all
    super.map{|x| {key: x.original_key, value: x.parse}}
  end

  def parse
    val = self.value
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

class Star < ActiveRecord::Base
end

class Stars
  def self.list user
    Pig.find Star.where(user_id: user).map{|x| x.key}
  end

  def self.star? user, key
    !!Star.where(user_id: user, key: key).first
  end

  def self.star user, key
    Star.find_or_create_by(user_id: user, key: key)
  end

  def self.unstar user, key
    s = Star.where(user_id: user, key: key).first
    s.destroy if s
  end
end

class Recent < ActiveRecord::Base
end

class Recents
  def self.list user
    hash = {}
    Recent.where(user_id: user).each{|r|
      hash[r.key] = {}
    }
    hash
  end

  def self.recent? user, key
    !!Recent.where(user_id: user, key: key).first
  rescue
    nil
  end

  def self.recent user, key
    Recent.find_or_create_by(user_id: user, key: key)
  end
end
