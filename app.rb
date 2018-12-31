# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'
require 'sqlite3'
# require "./lib/valid"

def errCheck(page, block)
  if page == :visit
    errHash = { username: 'Поле с именем пустое',
                phone: 'Поле с телефоном пустое',
                date_n_time: 'Поле с датой и временем пустое' }
  elsif page == :contacts
    errHash = { email: 'Введите email',
                message: 'Поле сообщения пустое' }
  elsif page == :admin
    errHash = { login: 'Поле с логином пустое',
                password: 'Введите пароль' }
  end

  @error = errHash.select { |key| params[key] == '' }.values.join('|')

  if @error != ''
    return erb page
  else
    block.call
  end
end

def is_barber_exist?(db, name)
  db.execute('select * from Barbers where name=?', [name]).length > 0
end

def seed_db db, barbers
	barbers.each do |barber|
		if !is_barber_exist? db, barber
			db.execute 'insert into Barbers (name) values (?)', [barber]
		end
	end
end

def get_db
  SQLite3::Database.new 'db/barber_shop.db'
end

before do
  db = get_db
  @barbers = db.execute 'select * from Barbers'
end

configure do
  db = get_db

  db.execute 'CREATE TABLE IF NOT EXISTS
		"Users"
		(
			"Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
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
  db.execute 'CREATE TABLE IF NOT EXISTS
	"Barbers"
	(
		"Id"	INTEGER PRIMARY KEY AUTOINCREMENT,
		"Name"	TEXT UNIQUE
	);'

  seed_db db, ['Henry', 'Jhon', 'Walter', 'Jessie']
end

get '/' do
  erb 'Hello! <a href="https://github.com/bootstrap-ruby/sinatra-bootstrap">Original</a> pattern has been modified for <a href="http://rubyschool.us/">Ruby School</a>'
end

get '/admin' do
  erb :admin
end

post '/admin' do
  db = get_db

  # db.results_as_hash = true --One day that'save your live

  block = lambda do
    if params[:login] == 'admin' && params[:password] == 'secret'
      @row_with_user_info = []
      db.execute 'select * from Users order by id desc' do |row|
        @row_with_user_info << row
      end

      erb :list_for_admin
    else
      redirect to '/admin'
    end
  end

  errCheck :admin, block
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

    erb "<h1>Вы успешно записались! Спасибо что пользуетесь нашими услугами!</h1>"
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

    Pony.mail(to: 'rubyhurma@gmail.com',
              from: 'My Barbershop',
              subject: "Barber shop message from #{params[:email]}",
              body: params[:message].to_s,
              via: :smtp,
              via_options: {
                address: 'smtp.gmail.com',
                port: '587',
                enable_starttls_auto: true,
                user_name: 'rubyhurma@gmail.com',
                password: '1098Hurma1895',
                authentication: :plain,
                domain: 'mail.google.com'
              })

    erb :contacts
  end

  errCheck :contacts, block
end
