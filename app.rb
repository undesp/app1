require 'rubygems'
require 'sinatra'

def get_user_name userNameFromFile
	File.open('user.txt','r') do |f|
		while line = f.gets
			if line.strip == userNameFromFile
				@password = f.gets.strip
				exit
			end
		end
	end

end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
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
		get_user_name params['username']

	 if params['username'] == 'admin' && params['password'] == '987654'
  		session[:identity] = params['username']
	  	where_user_came_from = session[:previous_url] || '/'
	  	redirect to where_user_came_from
	  else
	  	@message = 'access denied'
	  	#erb "<div class='alert alert-message'>Access denied</div>"
	  	erb :login_form
	  	

	end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
