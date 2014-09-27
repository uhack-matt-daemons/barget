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
end

get '/' do
	redirect '/info'
end

get '/login' do
	@msg = 'Bad login. Try again.' if params[:bad_attempt]
	redirect '/profileStats' if session[:user_id]
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
	@user = User.get(session[:user_id])
	redirect '/login' unless @user
	@items = @user.items.map {|i| Target.product(i)}
	render_page :profile
end

get '/profileStats' do
	@user = User.get(session[:user_id])
	redirect '/login' unless @user
	@items = $db.user_items(@user.id).group_by {|i| i[2]}
	str = ""
	@items.each do |id,ids|
		i=0
		diff=0
		p "id.length: #{ids.length}"
		while i< (ids.length-1) do
			p i
			p ids
			day2 = DateTime.parse(ids[i+1][3]).yday
			day1 = DateTime.parse(ids[i][3]).yday
			diff = diff + (day2 - day1)
			i = i + 1
		end
		diff = diff/i
		str += "#{id} #{diff}\n"
	end
	return str
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
	@items = []
	render_page :add_item
end

post '/product/add/search' do
	@items = Target.product_search(params[:query]).map {|id| Target.product id}
	render_page :add_item
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

get '/populate' do
	$db.populate().to_s
end
