case ARGV[0] 
when 'setup'
  require 'fileutils'
  config = Pit.get("Pig Media Server", require:{
    'path' => 'Path of your storage',
    'groonga' => "Path of groonga's files",
    'exclude_path' => 'Exclude Path(Array)',
    'user_data_path' => 'Path of User Data'
  })

  puts "Path: #{config['path']}"
  puts "Groonga: #{config['groonga']}"
  FileUtils.mkdir_p config['user_data_path']
when 'crawl'
  require 'pig-media-server/crawl'
  PigMediaServer::Crawl.new.all
when 'server'
  port = ARGV[1] ? ARGV[1].to_i : 8080
  require 'pig-media-server/web'
  PigMediaServer::Web.run! host: '0.0.0.0', port: port
end
