require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

configure do
  set :public_folder, 'public'
  enable :sessions
end

get '/' do
  'Hey, bitches. <a href="http://zxing.appspot.com/scan?ret=http%3A%2F%2F131.212.238.82:4567%2Fscanned%2F1%2F%7BCODE%7D&SCAN_FORMATS=UPC_A,EAN_13">click here fuckers</a>'
end

get '/login' do
  @msg = 'Bad login. Try again.' if params[:bad_attempt]
  redirect '/profile' if session[:user_id]
  erb File.read('views/login.erb')
end

post '/login' do
  user_id = $db.getUserID(params[:username])
  if user_id
    session[:user_id] = user_id
    redirect '/login'
  else
    redirect '/login?bad_attempt=true'
  end
end

get '/logout' do
  session[:user_id] = nil
  redirect '/login'
end

get '/profile' do
  @user = User.get(session[:user_id])
  @items = @user.items.map {|i| Target.product(i)}
  erb File.read('views/profile.erb')
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
