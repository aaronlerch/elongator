require 'sinatra'
require 'slim'
require 'redis'
require 'json'
require 'rest-client'
require 'CGI'

configure :development do
  uri = URI.parse('redis://localhost:6379')
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

configure :production do
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

helpers do
  def parse_urls
    urls = {}
    for param in (request.query_string || '').split("&")
      values = param.split("=")
      next if values[0].nil? or values[1].nil?
      url = values[0].downcase
      next if url != 'url'

      urls[CGI::unescape(values[1].strip)] = nil
    end

    return urls
  end

  def resolve_url(url)
    resolved_url = url
    RestClient.head(url) do |response, request, result, &block|
      resolved_url = response.headers[:location] if response.code == 301
    end
    return resolved_url
  end
end

get '/' do
  slim :index
end

get '/expand' do
  urls = parse_urls
  return if urls.empty?

  keys = urls.map { |key,value| "url:#{key}" }
  resolved_urls = REDIS.mget *keys  # <- mget takes params, not an array
  REDIS.multi do
    urls.each_with_index do |pair, index|
      if resolved_urls[index].nil?
        resolved = resolve_url(pair[0])
        urls[pair[0]] = resolved
        REDIS.set "url:#{pair[0]}", resolved
      else
        urls[pair[0]] = resolved_urls[index]
      end
    end
  end

  content_type :json
  urls.to_json
end
