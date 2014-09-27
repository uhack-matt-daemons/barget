require 'sinatra'

Dir['src/*.rb'].each {|file| require File.expand_path file }

configure do
	set :public_folder, 'public'
	enable :sessions
end

helpers do
	def render_page(view)
		@user = User.get(session[:user_id])
		@page = view
		erb view, :layout => :template
	end
	def validate_user
		@user = User.get(session[:user_id])
		redirect '/login' unless @user
	end
end

get '/' do
	redirect '/dash'
end

get '/login' do
	@msg = 'Bad login. Try again.' if params[:bad_attempt]
	redirect '/' if session[:user_id]
	render_page :login
end

post '/login' do
	user = User.find(params[:username])
	if user
		session[:user_id] = user.id
		redirect '/login'
	else
		redirect '/login?bad_attempt=true'
	end
end

get '/logout' do
	session[:user_id] = nil
	redirect '/login'
end

get '/dash' do
	validate_user
	@analytics = Analytics.user(@user.id).map{|e| e[2]}
	@a = Analytics.user(@user.id)
	render_page :dash
end

get '/items/list' do
	validate_user
	@items = @user.items.map {|i| Target.product(i)}
	render_page :list
end

get '/items/add' do
	validate_user
	@items = []
	render_page :add_item
end

post '/items/add/search' do
	validate_user
	@items = Target.product_search(params[:query]).map {|id| Target.product id}
	render_page :add_item
end

post '/items/add/*' do |dpci|
	validate_user
	@user.add_item(dpci)
	redirect '/items/list'
end

post '/items/expire/*' do |dpci|
	validate_user
	@user.expire_item(dpci)
	redirect '/items/list'
end

get '/items/add/barcode/*' do |dpci|
	validate_user
	@items = Target.product_search(dpci).map {|id| Target.product id}
	render_page :add_item
end

get '/about' do
	render_page :about
end

get '/analytics' do
	@a = Analytics.global
	render_page :analytics
end

