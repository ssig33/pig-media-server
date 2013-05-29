require 'pig-media-server'
require 'pig-media-server/model/pig'
require 'sinatra/base'
require 'sinatra/flash'
require 'net/http'
require 'sass'
require 'haml'
require 'coffee_script'
require 'rack/csrf'
require 'json'

module PigMediaServer
  class UserData
    def self.save json, user_id, path
      open("#{path}/#{user_id}.json", "w"){|f| f.puts json}
      true
    end

    def self.load user_id, path
      return JSON.parse(open("#{path}/#{user_id}.json").read) rescue return {}
    end
  end

  class Gyazo
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
    
    configure do
      set :sessions, true
      set :haml, escape_html: true
      set :haml, attr_wrapper: '"'
      use Rack::Session::Cookie, expire_after: 60*60*24*28, secret: $session_secret || rand(256**16).to_s(16)
    end
    
    get '/' do
      if params[:query]
        redirect '/latest' if params[:query].empty?
        @page = params[:page].to_i < 1 ? 1 : params[:page].to_i
        @action = 'list'
        @list = Pig.search params.merge(page: @page)
      end
      haml :index
    end

    get '/custom' do
      c = config['custom_list'][params[:name]]
      @page = params[:page].to_i < 1 ? 1 : params[:page].to_i
      @action = 'list'
      @list = Pig.find JSON.parse(open(c).read)
      haml :index
    end

    get '/latest' do
      @page = params[:page].to_i < 1 ? 1 : params[:page].to_i
      size = params[:size] ? params[:size].to_i : 50
      @list = Groonga['Files'].select.paginate([key: 'mtime', order: 'descending'], size: size, page: @page).map{|x| Pig.new(x)}
      @action = 'list'
      haml :index
    end

    post '/gyazo' do
      url = PigMediaServer::Gyazo.post params[:url], params[:point]
      content_type :json
      {url: url}.to_json
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

    post '/sessions' do
      session[:user_id] = params[:user_id]
      redirect '/'
    end

    get('/hash'){content_type :json; hash().to_json}
    post('/hash'){PigMediaServer::UserData.save params[:json], session[:user_id], config['user_data_path']}

    get('/config'){haml :config}
    get('/*.css'){scss params[:splat].first.to_sym}
    get('/*.js'){coffee params[:splat].first.to_sym}
    
    helpers do
      def config
        Pit.get "Pig Media Server"
      end
      def h str; CGI.escapeHTML str.to_s; end
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
      def hash
        if session[:user_id]
          return PigMediaServer::UserData.load session[:user_id], config['user_data_path']
        else
          return {}
        end
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
        nil
      end  
    end
  end

end
