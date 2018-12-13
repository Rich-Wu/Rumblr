require 'sinatra'
require 'sinatra/activerecord'

enable :sessions

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: "sqlite3", database: "database.sqlite3"}
end

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

get '/' do
  if session['user_id'] != nil
    @posts = Post.all.order(created_at: :desc)
  end
  erb :index
end

get '/join' do
  if session['user_id'] == nil
    erb :'users/createaccount'
  else
    redirect '/'
  end
end

post '/join' do
  if params[:password].length >= 8
    if params[:password] == params[:password_confirm]
      @user = User.new(email: params[:email], username: params[:email], first_name: params[:first_name], last_name: params[:last_name], password: params[:password], birthdate: params[:birthdate])
      @user.save
      session['user_id'] = @user.id
      redirect '/account'
    else
      @error = "Passwords must match"
    end
  else
    @error = "Password is too short"
  end
  erb :'users/createaccount'
end

get '/login' do
  erb :'users/login'
end

post '/login' do
  @user = User.find_by(email: params[:email])
  if @user != nil
    if @user.password == params[:password]
      session['user_id'] = @user.id
      redirect '/'
    else
      redirect '/login'
    end
  end
  redirect '/login'
end

get '/posts/?' do
  if session['user_id'] == nil
    redirect '/login'
  else
    @posts = Post.where(user_id: session['user_id']).order(created_at: :desc)
    erb :'posts/posts'
  end
end

post '/posts' do
  @post = Post.new(user_id: session['user_id'], title: params[:title], content: params[:content])
  @post.save
  redirect '/posts'
end

get '/account/?' do
  @user = User.find(session['user_id'])
  erb :'users/myaccount'
end

post '/account' do
# update profile information/settings
  @user = User.find(session['user_id'])
  if params[:password] != ""
    if params[:password] == @user.password
      @user.username = params[:username]
      @user.first_name = params[:first_name]
      @user.last_name = params[:last_name]
      @user.save
      if params[:new_password] != ""
        if params[:new_password].length>=8
          @user.password = params[:new_password]
          @user.save
          @success = true
        else
          @error = "New password is invalid"
        end
      end
    else
      @error = "Incorrect Password"
    end
  end
  erb :'users/myaccount'
end

get '/logout' do
  session['user_id'] = nil
  redirect '/'
end
