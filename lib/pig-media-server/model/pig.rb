#coding:utf-8
require 'fileutils'
require 'pig-media-server/model/migrate'
require 'pig-media-server/model/data'

CONFIG = Pit.get('Pig Media Server')

class Pig
  attr_accessor :record, :config
  def initialize record
    unless record.size
      record.size = File::Stat.new(record.path).size.to_s rescue nil
    end
    self.record = record
    self.config = CONFIG
  end
  def key; self.record._key;end
  def name; self.record.path.split('/').last; end
  def mtime; Time.at(self.record.mtime);end
  def size; self.record.size;end
  def metadata; self.record.metadata;end
  def srt; self.record.srt;end
  def url; 'http://'+self.config['hostname']+ '/volume' + URI.encode(self.record.path.sub(/#{config['path'].sub(/\//, '\/')}/, ''));end
  def type
    case self.name.split('.').last
    when 'mp4', 'MP4', 'webm'
      'video'
    when 'zip', 'ZIP'
      'read'
    when 'pdf'
      'pdf'
    when 'txt', 'TXT'
      'txt'
    when 'mobi'
      'mobi'
    when 'flv'
      'flv'
    else
      'other'
    end
  end
  def path
    self.record.path.sub(/#{config['path'].sub(/\//, '\/')}/, '')
  end
  def comic
    Comic.new self.record
  end
  def webvtt
str = <<EOS 
WEBVTT

#{self.srt.split("\n").delete_if{|x| x.to_i.to_s == x.chomp}.map{|x| if x =~ /\d\d:\d\d/; x.gsub!(/,/, '.');else; x = x.gsub(/</, '＜').gsub(/>/, '＞');end; x}.join("\n")}
EOS
str.chomp.chomp
  end
  def to_kindle user_id
    FileUtils.mkdir_p "#{self.config['user_data_path']}/kindle/queue"
    open("#{self.config['user_data_path']}/kindle/queue/#{self.key}_#{user_id}", 'w'){|x| x.puts ''}
  end
  def change_aspect_rate rate
    FileUtils.mkdir_p "#{self.config['user_data_path']}/rate"
    open("#{self.config['user_data_path']}/rate/queue.txt", "a"){|x| x.puts "#{self.key} #{rate}"}
  end



  def self.find key
    case key.class.to_s
    when 'Array'
      return key.map{|x| Groonga['Files'][x]}.select{|x| x}.map{|x| self.new x}
    when 'String'
      return self.new Groonga['Files'][key]
    end
  end

  def self.search opts
    query = Sewell.generate opts[:query].to_s, %w{metadata path srt}
    limit = opts[:limit] ? opts[:limit].to_i : 50
    page = opts[:page].to_i < 1 ? 1 : opts[:page].to_i
    order = (opts[:order] == 'ascending' or opts[:order] == 'descending') ? opts[:order] : 'descending'
    result = Groonga['Files'].select(query)
    if result.count == 0
      begin
        result = Groonga['Files'].select{|x| x.path.match str}
      rescue
      end
    end
    if opts[:sort] == 'name'
      list = result.paginate([key: 'path', order: order], size: 2000, page: page).map{|x| Pig.new x}.sort{|x,y| 
        x.path.split('/').last.sub(/^\d\d*_/, '') <=> y.path.split('/').last.sub(/^\d\d*_/, '')
      }.reverse rescue list = []
      list.reverse! if order == 'descending'
    else
      list = result.paginate([key: 'mtime', order: order], size: limit, page: page).map{|x| Pig.new x} rescue list = []
    end
    list
  end

  def self.find_or_create_by_path path
    key = Digest::MD5.hexdigest(path).to_s
    unless Groonga['Files'][key]
      stat = File::Stat.new path
      Groonga["Files"].add(key)
      Groonga["Files"][key].path = path
      Groonga["Files"][key].mtime = stat.mtime.to_i
      Groonga['Files'][key].size = stat.size.to_s
    end
    return Pig.new Groonga['Files'][key]
  end

  def self.all
    Groonga['Files'].select.map{|x| Pig.new x}
  end

  def check
    return false unless self.record
    Groonga['Files'].delete self.record._key unless File.exist? self.record.path
  end
end
