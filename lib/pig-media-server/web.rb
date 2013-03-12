require 'pig-media-server'
require 'pig-media-server/model/pig'
require 'sinatra/base'
require 'sinatra/flash'
require 'net/http'
require 'sass'
require 'coffee_script'

module PigMediaServer
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
      use Rack::Session::Cookie, key: 'rack.session', expire_after: 60*60*24*28, secret: rand(256**16).to_s(16)
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

    get('/config'){haml :config}
    get('/*.css'){scss params[:splat].first.to_sym}
    get('/*.js'){coffee params[:splat].first.to_sym}

    helpers do
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
