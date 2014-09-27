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
	redirect '/info'
end

get '/login' do
	@msg = 'Bad login. Try again.' if params[:bad_attempt]
	redirect '/profile' if session[:user_id]
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

get '/profile' do
	validate_user
	@items = @user.items.map {|i| Target.product(i)}
	render_page :profile
end

get '/scanned/*/*' do |user,barcode|
	if $db.item_add(user,Target.product_search(barcode)[0])
		@content = 'Added item'
	else
		@content = 'Fuck, didn\'t work'
	end
	render_page :blank
end

get '/product/add' do
	validate_user
	@items = []
	render_page :add_item
end

post '/product/add/search' do
	validate_user
	@items = Target.product_search(params[:query]).map {|id| Target.product id}
	render_page :add_item
end

post '/product/add/*' do |dpci|
	validate_user
	@user.add_item(dpci)
	redirect '/profile'
end

get '/product/search/*' do |searchTerm|
	view = ''
	Target.product_search(searchTerm).each do |id|
		view += Target.product(id).render
	end
	@content = view
	render_page :blank
end

get '/product/*' do |id|
	product = Target.product(id)
	@content = product.render
	render_page :blank
end

get '/about' do
	render_page :about
end
