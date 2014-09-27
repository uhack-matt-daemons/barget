require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

$users = {
    'josh' => 0,
    'foo' => 1
}

configure do
  set :public_folder, 'public'
  enable :sessions
end

get '/' do
  'Hey, bitches. <a href="http://zxing.appspot.com/scan?ret=http%3A%2F%2F131.212.238.82:4567%2Fscanned%2F1%2F%7BCODE%7D&SCAN_FORMATS=UPC_A,EAN_13">click here fuckers</a>'
end

get '/login' do
  redirect '/profile' if session[:user_id]
  erb File.read('views/login.erb')
end

get '/logout' do
  session[:user_id] = nil
  redirect '/login'
end

get '/profile' do
  "You are logged in as #{session[:user_id]}" +
      '<a href="/logout">Logout</a>'
end

post '/login' do
  username = params[:username]
  if $users.has_key? username
    session[:user_id] = $users[username]
    redirect '/login'
  else
    'Bad login.'
  end
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
end
