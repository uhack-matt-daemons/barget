require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

get '/' do
  'Hey, bitches.'
end

get '/product/search/*' do |searchTerm|
  view = ''
  Target.product_search(searchTerm).each do |id|
    view += Target.product(id).render
  end
  view
end

get '/product/*' do |id|
  product = Target.product(id)
  product.render
end
