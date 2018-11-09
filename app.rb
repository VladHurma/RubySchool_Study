#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require "./valid"

def errCheck (page)

		errHash = {:username => 'Поле с именем пустое',
		:phone => 'Поле с телефоном пустое',
		:date_n_time => 'Поле с датой и временем пустое'}

		@error = errHash.select{|key| params[key] == ''}.values.join('|')

		if @error != ''
			return erb page
		end

end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do	
	@username = params[:username]
	@phone = params[:phone]
	@date_n_time = params[:date_n_time]
	@master = params[:master]
	@select = params[:select]
	@color = params[:colorpicker]

	errCheck :visit

	f = File.open 'public/users.txt', "a"
	f.write "\nZ\n#{@username}\n#{@phone}\n#{@date_n_time}\n#{@master}\n#{@select}\n#{@color}"
	f.close

	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@email = params[:email]
	@message = params[:message]

	f = File.open 'public/contacts.txt', "a"
	f.write "Email:\n#{@email}\nСообщение:\n#{@message}\n\n\n"
	f.close

	erb :contacts
end

get '/admin' do
	erb :admin
end

post '/admin' do
	@login = params[:login]
	@password = params[:password]

	if @login == "admin" && @password == "secret"
		@logfile = File.read("public/users.txt")
		@seclog = File.read("public/contacts.txt")
		erb :adminList
    else
		redirect to "/admin"
	end
			
end