require 'active_support/concern'
module PigMediaServer
  module API
    extend ActiveSupport::Concern
    def page
      params[:page].to_i < 1 ? 1 : params[:page].to_i
    end

    def size
      params[:size] ? params[:size].to_i : 50
    end

    def list_to_json list
      list.map{|x| 
        hash = x.to_hash
        hash['custom_links'] = partial :_custom_links, locals: {record: x}
        hash['metadata'] = !!x.metadata and x.metadata != ''
        hash['srt'] = !!x.metadata and x.metadata != ''
        hash
      }.to_json
    end

    included do
      get '/api/r/latest' do
        content_type :json
        list_to_json(Groonga['Files'].select.paginate([key: 'mtime', order: 'descending'], size: size, page: page).map{|x| Pig.new(x)})
      end

      get '/api/r/custom' do
        content_type :json
        c = config['custom_list'][params[:name]]
        list_to_json(Pig.find JSON.parse(open(c).read))
      end

      get '/api/r/recommend' do
        content_type :json
        list = []
        begin
          keys = open("#{config['user_data_path']}/recommend/#{params[:name]}").read.split("\n")
          list = Pig.find(keys)
        rescue
        end
        list_to_json(list)
      end

      get '/api/r/search' do
        content_type :json
        list_to_json(Pig.search params.merge(page: page))
      end

      get '/api/r/config' do
        content_type :json
        config.to_json
      end

      get '/api/r/session' do
        content_type :json
        session.to_hash.to_json
      end

      get '/api/r/custom_list' do
        content_type :json
        if config['custom_list']
          config['custom_list'].to_json
        else
          {}.to_json
        end
      end

      get '/api/r/query_list' do
        content_type :json
        Groonga['QueryList'].select.map{|x| x.query }.sort.to_json
      end

      post '/api/r/query_list' do
        content_type :json
        key = Digest::MD5.hexdigest(params[:query])
        unless Groonga['QueryList'][key]
          Groonga['QueryList'].add(key)
          Groonga['QueryList'][key].query = params[:query]
        end
        {result: true}.to_json
      end

      post '/api/r/delete_query_list' do
        content_type :json
        key = Digest::MD5.hexdigest(params[:query])
        if Groonga['QueryList'][key]
          Groonga['QueryList'].delete key
        end
        {result: true}.to_json

      end
    end
  end
end
