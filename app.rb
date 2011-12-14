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
    url_list = []
    for param in (request.query_string || '').split("&")
      values = param.split("=")
      next if values[0].nil? or values[1].nil?
      url = values[0].downcase
      next if url != 'url'

      url_list << CGI::unescape(values[1].strip)
    end

    return url_list
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

  resolved_urls = REDIS.mget(urls.map { |url| "url:#{url}" })
  REDIS.multi do
    resolved_urls.each_with_index do |url, index|
      if url.nil?
        resolved = resolve_url(urls[index])
        resolved_urls[index] = resolved
        REDIS.set "url:#{urls[index]}", resolved
      end
    end
  end

  content_type :json
  resolved_urls.to_json
end
