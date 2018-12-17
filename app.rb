#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'
#require "./lib/valid"

def errCheck(page, block)

	if page == :visit
		errHash = {:username => 'Поле с именем пустое',
		:phone => 'Поле с телефоном пустое',
		:date_n_time => 'Поле с датой и временем пустое'}
	elsif page == :contacts
		errHash = {:email => 'Введите email',
			:message => 'Поле сообщения пустое'}
	end

		@error = errHash.select{|key| params[key] == ''}.values.join('|')

		if @error != ''
			return erb page
		else
			block.call
		end

end

def get_db
	return SQLite3::Database.new 'db/barber_shop.db'
end

configure do
	db = get_db

	db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"ID"	INTEGER PRIMARY KEY AUTOINCREMENT,
			"Name"	TEXT,
			"Phone"	TEXT,
			"Date_stamp"	TEXT,
			"Barber"	TEXT,
			"Color"	TEXT
		);'
	
	db.execute 'CREATE TABLE IF NOT EXISTS
		"Contacts"
		(
			"Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
			"Email"	TEXT,
			"Message"	TEXT
		);'
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

	db = get_db

	block = lambda do
		db.execute 'insert into
		Users
		(
			name,
			phone,
			date_stamp,
			barber,
			color
		)
		values (?, ?, ?, ?, ?)', [params[:username], params[:phone],
			params[:date_stamp], params[:barber], params[:colorpicker]]
	
		erb :visit
	end

	errCheck :visit, block

end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	
	db = get_db

	block = lambda do
		db.execute 'insert into
		Contacts
		(
			email,
			message
		)
		values (?, ?)', [params[:email], params[:message]]
	
		Pony.mail(:to => 'rubyhurma@gmail.com',
			:from => "My Barbershop",
			:subject => "Barber shop message from #{params[:email]}",
			:body => "#{params[:message]}",
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

		erb :contacts
	end

	errCheck :contacts, block

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