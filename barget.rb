require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

get '/' do
  'Hey, bitches.'
end

get '/product/search/*' do |searchTerm|
  Target.product_search searchTerm
end