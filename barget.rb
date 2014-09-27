require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

get '/' do
  'Hey, bitches. <a href="http://zxing.appspot.com/scan?ret=http%3A%2F%2F131.212.238.82:4567%2Fscanned%2F1%2F%7BCODE%7D&SCAN_FORMATS=UPC_A,EAN_13">click here fuckers</a>'
end

get '/scanned/*/*' do |user,barcode|
	"#{user} scanned a #{barcode}."
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
  Target.product_search searchTerm
end
