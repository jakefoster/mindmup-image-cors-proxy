require 'sinatra'
require 'open-uri'
require 'net/http'

configure do
  set :cors_header, ENV['CORS_HEADER'] || '*'
end
get '/' do
  halt 404 unless params[:u]
  uri=URI.parse(params[:u])
  begin
    result = uri.read
    halt 200, {'Access-Control-Allow-Origin' => settings.cors_header, 'Content-Type' => result.content_type}, result
  rescue Exception => e
    puts "Error proxying\t#{params[:u]}\t#{e.message}\tTrace:\t#{e.backtrace.inspect}"
    halt 404
  end
end

