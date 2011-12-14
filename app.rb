require 'sinatra'
require 'slim'
require 'redis'
require 'json'

configure :development do
  uri = URI.parse('redis://localhost:6379')
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

configure :production do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

helpers do
  def urls
    hash = {}
    for param in (request.query_string || '').split("&")
      values = param.split("=")
      next if values[0].nil? or values[1].nil?
      url = values[0].downcase.to_sym
      next if url != :url

      hash[url] = [] if hash[url].nil?
      hash[url] << values[1]
    end
    return hash
  end
end

get '/' do
  slim :index
end

get '/expand' do
  # REDIS.get "url:#{url}"
  # REDIS.set "url:#{url}", redirected_url
  # for each url in urls[:url], do a HEAD request
  # content_type :json
end
