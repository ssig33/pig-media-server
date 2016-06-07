require 'pig-media-server'
require 'pig-media-server/api'
require 'pig-media-server/model/pig'
require 'pig-media-server/model/comic'
require 'sinatra/base'
require 'sinatra/flash'
require 'net/http'
require 'sass'
require 'haml'
require 'builder'
require 'fileutils'
require 'coffee_script'
require 'rack/csrf'
require 'redcarpet'
require 'json'
require 'twitter'
require 'tempfile'
require 'tmpdir'


module PigMediaServer
  CONFIG = Pit.get 'Pig Media Sever'
  class UserData
    def self.save user_id, key, value
      AppData.set("user_data/#{user_id}/#{key}", value)
    end

    def self.load user_id, key
      AppData.find("user_data/#{user_id}/#{key}")
    end
  end

  class Gyazo
    def self.tweet url, comment, key, secret, token, token_secret, c
      Dir.mktmpdir do |dir|
        name = dir + "/#{rand(256**16).to_s(16)}.png"
        jpg = name.sub(/png$/, 'jpg')
        img = url.sub(/data:image\/png;base64,/, '').unpack('m').first
        open(name, 'w'){|f| f.puts img}
        system "gm", "convert", name, jpg
        jpg = name unless File.exists? jpg
        client = Twitter::REST::Client.new do |config|
          config.consumer_key = key
          config.consumer_secret = secret
          config.access_token = token
          config.access_token_secret = token_secret
        end

        client.update_with_media(comment.to_s, open(jpg))# rescue nil
        FileUtils.rm name rescue nil
        FileUtils.rm jpg rescue nil
      end
    end

    def self.post url, point
      imagedata = url.sub(/data:image\/png;base64,/, '').unpack('m').first
      boundary = '----BOUNDARYBOUNDARY----'
      id = rand(256**16).to_s(16)

      data = <<EOF
--#{boundary}\r
content-disposition: form-data; name="id"\r
\r
      #{id}\r
--#{boundary}\r
content-disposition: form-data; name="imagedata"; filename="gyazo.com"\r
\r
      #{imagedata}\r
--#{boundary}--\r
EOF
      header ={
        'Content-Length' => data.length.to_s,
        'Content-type' => "multipart/form-data; boundary=#{boundary}",
        'User-Agent' => 'ssig33.com/1.0'
      }
      proxy_host, proxy_port = nil, nil
      uri = URI.parse point
      Net::HTTP::Proxy(proxy_host, proxy_port).start(uri.host,80) {|http|
        res = http.post(uri.path, data, header).body
        puts res
        return res
      }
    end
  end

  class Web < Sinatra::Base
    register Sinatra::Flash
    include PigMediaServer::API

    configure do
      set :haml, escape_html: true
      set :haml, attr_wrapper: '"'
      set :logging, true
      use Rack::Session::Cookie, key: 'pigmeidaserver', secret: $session_secret || rand(256**16).to_s(16)
    end

    get '/' do
      haml :react
    end

    get '/feed' do
      @list = Pig.search params.merge(page: @page)
      content_type :xml#'application/rss+xml'
      builder :feed
    end

    get '/custom' do
      haml :react
    end

    get '/latest' do
      haml :react
    end

    get '/recommend' do
      haml :react
    end

    #get('/meta/:key'){@p = Pig.find(params[:key]);haml :meta}
    get('/meta/:key') do
      haml :react
    end

    get('/sub/:key'){@p = Pig.find(params[:key]);haml :sub}
    get('/webvtt/:key'){@p = Pig.find(params[:key]); content_type :text; @p.webvtt}
    get '/delete/:key' do
      p = Groonga['Files'][params[:key]]
      path = "#{config['recycle_path']}/#{Date.today}/"
      FileUtils.mkdir_p path unless File.exist? path
      FileUtils.mv p.path, path rescue nil
      Groonga['Files'].delete params[:key]
      redirect params[:href]
    end

    get '/read/:key' do
      if request.xhr?
        @record = Pig.find params[:key] rescue nil
        @comic = @record.comic
        haml :read
      else
        raise
      end
    end

    get('/book/info/:key'){ content_type :json; Pig.find(params[:key]).comic.info(params[:page]).to_json}
    get '/book/image' do
      image, type = Pig.find(params[:id]).comic.page(params[:page])
      content_type type
      image
    end

    get "/change_aspect_rate/:key" do
      Pig.find(params[:key]).change_aspect_rate(params[:rate])
      redirect "/meta/#{params[:key]}"
    end

    post '/gyazo' do
      url = PigMediaServer::Gyazo.post params[:url], params[:point]
      content_type :json
      {url: url}.to_json
    end

    post '/gyazo/tweet' do
      consumer_key = UserData.load session[:user_id], 'consumer_key'
      consumer_secret = UserData.load session[:user_id], 'consumer_secret'
      token = UserData.load session[:user_id], 'token'
      token_secret = UserData.load session[:user_id], 'token_secret'
      PigMediaServer::Gyazo.tweet params[:url], params[:comment], consumer_key, consumer_secret, token, token_secret, config()
      true
    end

    get '/remote' do
      if request.xhr? and params[:key]
        return partial :_link, locals: {l: Pig.find(params[:key])}
      end

      return haml :remote
    end

    get '/sessions' do
      if session[:user_id]
        session[:user_id] = nil
        redirect '/'
      else
        haml :sessions
      end
    end

    get '/to_kindle/:key' do
      flash[:notice] = 'Request Accepted. Please wait minutes.'
      Pig.find(params[:key]).to_kindle(session[:user_id])
      if params[:path]
        redirect params[:path]
      else
        redirect "/ao/#{params[:key]}"
      end
    end

    post '/sessions' do
      session[:user_id] = params[:user_id]
      p session
      redirect '/'
    end

    get '/tv' do
      @action = 'list'
      haml :tv
    end

    get '/tv/list' do
      content_type :json
      UserData.load(session[:user_id], 'tv-list').to_json
    end

    post '/tv/list' do
      UserData.save(session[:user_id], 'tv-list', JSON.parse(params[:data]))
    end

    get('/data'){UserData.load(session[:user_id], params[:key])}
    post('/data'){UserData.save(session[:user_id], params[:key], params[:value])}
    get('/recents'){content_type :json; p session[:user_id];Recents.list(session[:user_id]).to_json}
    post '/recents' do
      JSON.parse(params[:data]).each{|k,v|
        Recents.recent session[:user_id], k
      }
      'true'
    end

    get('/config'){haml :config}
    get('/book2.js'){content_type :js;erb :book2}
    get('/swipe.js'){content_type :js;erb :swipe}
    get('/*.css'){scss params[:splat].first.to_sym}
    get('/bundle.js'){content_type :js; open(File::dirname(__FILE__)+"/views/bundle.js").read}
    get('/*.js'){coffee params[:splat].first.to_sym}

    post '/api/save' do
      key = Digest::MD5.hexdigest(params[:name]).to_s
      FileUtils.mkdir_p "#{config['user_data_path']}/api_data"
      open("#{config['user_data_path']}/api_data/#{key}", 'w'){|x| x.puts params[:body]}
      true
    end

    get '/api/get' do
      key = Digest::MD5.hexdigest(params[:name]).to_s
      FileUtils.mkdir_p "#{config['user_data_path']}/api_data"
      if File.exist? "#{config['user_data_path']}/api_data/#{key}"
        open("#{config['user_data_path']}/api_data/#{key}").read
      else
        nil
      end
    end

    post '/api/capapi' do
      record = Groonga['Files'][params[:key]]
      name = "#{rand(256**16).to_s(16)}.jpg"
      system "avconv -ss #{params[:time]}  -i \"#{record.path}\" -f image2 -s 1280x720 -vframes 1 #{config['gyazo_path']}/#{name}"
      #system "gm convert -resize 1280x720! #{config['gyazo_path']}/#{name} #{config['gyazo_path']}/#{name}"
      "#{config['gyazo_prefix']}/#{name}"
    end

    get '/star' do
      Stars.star(session[:user_id], params[:key])
      redirect params[:href]
    end

    get '/stars' do
      @page = params[:page].to_i < 1 ? 1 : params[:page].to_i
      @action = 'list'
      @list = Stars.list session[:user_id]
      haml :index
    end

    helpers do
      def config
        $config = Pit.get("Pig Media Server") unless $config
        $config['page_title'] = 'Pig Media Server' unless $config['page_title']
        $config
      end

      def h str; CGI.escapeHTML str.to_s; end

      def remote?
        UserData.load(session[:user_id], 'remote')
      end

      def partial(template, *args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.merge!(:layout => false)
        if collection = options.delete(:collection) then
          collection.inject([]) do |buffer, member|
            buffer << haml(template, options.merge(:layout => false, :locals => {template => member}))
          end.join("\n")
        else
          haml(template, options)
        end
      end

      def star? key
        Stars.star?(session[:user_id], key)
      end

      def markdown str
        str = str.to_s
        Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(hard_wrap: true), autolink: true, fenced_code_blocks: true).render(str)
      end

      def number_to_human_size(number, precision = 1)
        number = begin
                   Float(number)
                 rescue ArgumentError, TypeError
                   return number
                 end

        case
        when number.to_i == 1 then
          "1 Byte"
        when number < 1024 then
          "%d Bytes" % number
        when number < 1048576 then
          "%.#{precision}f KB"  % (number / 1024)
        when number < 1073741824 then
          "%.#{precision}f MB"  % (number / 1048576)
        when number < 1099511627776 then
          "%.#{precision}f GB"  % (number / 1073741824)
        else
          "%.#{precision}f TB"  % (number / 1099511627776)
        end.sub(/([0-9]\.\d*?)0+ /, '\1 ' ).sub(/\. /,' ').encode('UTF-8')
      rescue
        ""
      end

      def title
        base = $config['page_title']
        return "#{params[:query]} - #{base}" if params[:query]
        return "#{@p.name} - #{base}" if @p
        base
      end
    end
  end
end
