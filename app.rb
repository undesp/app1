require 'rubygems'
require 'sinatra'
require 'Digest'
require 'sinatra/reloader'
require 'CSV'
require 'pg'


set :bind, '0.0.0.0'

@password = ''

#получить пароль пароль из файла по имени пользователя
def get_password_from_file userNameFromPost
	File.open('./users.txt','r:ASCII-8BIT') do |f|
		while line = f.gets
			if line.strip == userNameFromPost
				@password = f.gets.strip
				break
			end
		end
	end
end

#Слить информацию по записи к парикмахеру в файл /public/users.txt
def info_into_file file, hh
	File.open(file,'a') do |f|
		f.write "Имя: #{hh['inputName']}
E-mail: #{hh['inputEmail3']}
Номер телефона: #{hh['inputPhone']}
Записан на: #{hh['inputDateTime']}
К специалисту: #{hh['inputSpecialist']}
Цвет краски: #{hh['colorpicker']}\n\n"
	end
end

def info_into_file_csv file, hh
	File.open(file,'a') do |f|
		f.write "#{hh['inputName']},#{hh['inputEmail3']},#{hh['inputPhone']},#{hh['inputDateTime']},#{hh['inputSpecialist']},#{hh['colorpicker']}\n"
	end
end


configure do
  enable :sessions

	#begin
	    @db = PG.connect :dbname => 'app1', :user => 'user', :password => 'qwe'
	    @db.exec ("CREATE TABLE IF NOT EXISTS public.users
					(   id serial NOT NULL,
					    name text,
					    email text,
					    phone text,
					    dateStamp text,
					    specialist text,
					    color text,
					    PRIMARY KEY (id)
					)
					WITH (
					    OIDS = FALSE
					)
					TABLESPACE pg_default")
	    #@db.exec ('ALTER TABLE public.users					    OWNER to user;')
	    @error = @db.server_version

	#rescue PG::Error => e
	#    @error = e.message 
	#ensure
	#    @db.close if @db
	#end
end

helpers do
  def username

     session[:identity] ? session[:identity] : 'Гость'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'

end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
		get_password_from_file params['username']
		pass_hash = Digest::SHA2.new(512).digest(params['password'])
	 if  pass_hash == @password
	  		session[:identity] = params['username']
		  	where_user_came_from = session[:previous_url] || '/'
		  	redirect to where_user_came_from
		  	#redirect '/secure/place'
	  else
	  	@error = 'Access denied!'
		 halt erb(:login_form)
	end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do	
   erb :private

end


get '/visit' do
  erb :visit
end
post '/visit' do
	 
	
	@inputName = params[:inputName]
	@inputEmail3 = params[:inputEmail3]
	@inputPhone = params[:inputPhone]
	@inputDateTime = params[:inputDateTime]
	@inputSpecialist = params[:inputSpecialist]
	@colorpicker = params[:colorpicker]

	# хеш
	hh = { 	:inputName => ' имя',
			:inputEmail3 => ' E-mail',
			:inputPhone => ' телефон',
			:inputDateTime => ' дату и время'
			 }

	
	@error = hh.select {|key,_| params[key] == ""}.values.join(", ")
	if @error != ''
		@error =  'Введите: ' + @error
		return erb :visit 
	end


	@error = nil
	info_into_file './public/zapis.txt', params
	info_into_file_csv './public/zapis2.csv', params
	erb	 "Вы записаны к <%=params['inputSpecialist']%> на <%=params['inputDateTime']%>"

		
end

post '/contacts' do
	File.open('./public/contacts.txt','a') do |f|
		f.write "#{params['inputEmail']}\n#{params['contactsText']}\n\n"
	end
	
	erb "Спасибо за Ваш отзыв!"
end



get '/contacts' do
  erb :contacts
end

get '/about' do
	    @error = 'Thi is the error!!'
  erb :about
end
