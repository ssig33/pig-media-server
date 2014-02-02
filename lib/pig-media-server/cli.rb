require 'thor'

module PigMediaServer
  class CLI < Thor
    desc 'setup', 'setup configurations'
    def setup
      require 'fileutils'
      config = Pit.get("Pig Media Server", require:{
        'hostname' => 'Your host name',
        'path' => 'Path of your storage',
        'groonga' => "Path of groonga's files",
        'exclude_path' => 'Exclude Path(Array)',
        'user_data_path' => 'Path of User Data'
      })

      puts "Path: #{config['path']}"
      puts "Groonga: #{config['groonga']}"
      FileUtils.mkdir_p config['user_data_path']
    end

    desc 'crawl', 'run crawler'
    def crawl
      require 'pig-media-server/crawl'
      PigMediaServer::Crawl.new.all
    end

    desc 'server [PORT]', 'run server'
    option :bind, :type => :string, :default => '0.0.0.0'
    option :port, :type => :numeric, :default => 8080
    def server(port = nil)
      require 'pig-media-server/web'
      port ||= options[:port]
      Sinatra::Base.server.delete 'HTTP' # conflict with HTTP.gem
      PigMediaServer::Web.run! :bind => options[:bind], :port => port.to_i
    end

    desc 'aspect', 'fix aspect'
    def aspect
      require 'pig-media-server/aspect'
      PigMediaServer::Aspect.new.run
    end

    desc 'kindle-send', 'send to kindle'
    def kindle_send
      require 'pig-media-server/kindle_send'
      PigMediaServer::KindleSend.new.run
    end

    desc 'backup', 'backup groonga\'s data'
    def backup
      require 'pig-media-server/backup'
      PigMediaServer::Backup.new.backup
    end
    
    option :path, required: true
    desc 'restore', 'restore groonga\'s data'
    def restore
      require 'pig-media-server/backup'
      PigMediaServer::Backup.new.restore_from options[:path]
    end
  end
end
