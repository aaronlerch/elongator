require 'sinatra'
require 'slim'
require 'json'
require 'base64'

MAX_URL_LENGTH = 1900
LETTERS = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten.freeze

disable :static

get '/' do
  slim :index
end

get '/index.css' do
  filename = File.dirname(__FILE__) + "/public/index.css"
  content_type 'text/css'
  send_file filename
end

get '/title.png' do
  filename = File.dirname(__FILE__) + "/public/title.png"
  content_type :png
  send_file filename
end

get '/favicon.ico' do
  404
end

get '/elongate' do
  content_type 'application/json'

  encoded_url = Base64.strict_encode64(params[:url]) + "|"
  random_length = MAX_URL_LENGTH - encoded_url.length
  random_filler =  (0..random_length).map{ LETTERS[rand(LETTERS.length)] }.join
  {
    :original_url => params[:url],
    :elongated_url => url("/#{encoded_url}#{random_filler}")
  }.to_json
end

get '/:longurl' do
  begin
    base64_url = params[:longurl].split("|")[0]
    url = Base64.strict_decode64(base64_url)
    if !(url =~ /^[a-z]+:\/\//i)
      url = "http://" + url
    end
    redirect url, 301
  rescue
    status 404
  end
end
