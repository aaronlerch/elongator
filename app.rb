require 'sinatra'
require 'slim'
require 'json'
require 'base64'

get '/' do
  slim :index
end

get '/elongate' do
  content_type 'application/json'
  {
    :original_url => params[:url],
    :elongated_url => url("/#{Base64.strict_encode64(params[:url])}")
  }.to_json
end

get '/:longurl' do
  url = Base64.strict_decode64(params[:longurl])
  redirect url
end
