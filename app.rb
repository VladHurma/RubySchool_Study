#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
#require "./lib/valid"

def errCheck(page)

	if page == :visit
		errHash = {:username => 'Поле с именем пустое',
		:phone => 'Поле с телефоном пустое',
		:date_n_time => 'Поле с датой и временем пустое'}
	elsif page == :contacts
		errHash = {:email => 'Введите email',
			:message => 'Поле сообщения пустое'}
	end

		@error = errHash.select{|key| params[key] == ''}.values.join('|')
		@cheker = true

		if @error != ''
			@cheker = false
		end

		if @cheker == true && page == :visit
			f = File.open 'public/users.txt', "a"
			f.write "\nZ\n#{@username}\n#{@phone}\n#{@date_n_time}\n#{@master}\n#{@select}\n#{@color}"
			f.close
		elsif @cheker == false && page == :visit
			erb :visit
		end

		if @cheker == true && page == :contacts
			Pony.mail(:to => 'rubyhurma@gmail.com',
			:from => "My Barbershop",
			:subject => "Barber shop message form #{@email}",
			:body => "#{@message}",
			:via => :smtp,
			:via_options => {
				:address => 'smtp.gmail.com',
				:port => '587',
				:enable_starttls_auto => true,
				:user_name => 'rubyhurma@gmail.com',
				:password => '1098Hurma1895',
				:authentication => :plain, 
	            :domain => "mail.google.com"}
			)
		elsif @cheker == false && page == :contacts
			erb :contacts	
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
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	@email = params[:email]
	@message = params[:message]
	errCheck :contacts
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