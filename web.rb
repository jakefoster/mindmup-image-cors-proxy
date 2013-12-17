require 'sinatra'
require 'open-uri'
require 'net/http'

configure do
  set :cors_header, ENV['CORS_HEADER'] || '*'
  set :allowed_hosts, ENV['ALLOWED_HOSTS'].split(',')
  set :max_size, (ENV['MAX_SIZE']||200000).to_i
end
def fail_with message
  puts "error\t #{message}"
  halt 403, message
end
get '/' do
  fail_with 'URL not provided' unless params[:u]
  uri=URI.parse(params[:u])
  begin
    result = uri.read :content_length_proc => lambda{|length| fail_with "Image too large #{length}" if length>settings.max_size}
    fail_with "Domain #{request.referrer} not supported" unless settings.allowed_hosts.include? URI.parse(request.referrer || '').host 
    fail_with "Content type #{result.content_type} not supported" unless result.content_type.start_with? 'image'
    halt 200, {'Access-Control-Allow-Origin' => settings.cors_header, 'Content-Type' => result.content_type}, result
  rescue Exception => e
    puts "Error proxying\t#{params[:u]}\t#{e.message}\tTrace:\t#{e.backtrace.inspect}"
    halt 404
  end
end

