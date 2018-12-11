require 'sinatra'
require 'sinatra/activerecord'

enable :sessions

set :database, {adapter: "sqlite3", database: "database.sqlite3"}

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

get '/' do
  erb :index
end

get '/join' do
  if session['user_id'] != nil
    redirect '/account'
  else
    erb :'users/createaccount'
  end
end

post '/join' do
  @user = User.new(email: params[:email], first_name: params[:first_name], last_name: params[:last_name], password: params[:password], birthdate: params[:birthdate])
  @user.save
  session['user_id'] = @user.id
  redirect '/account'
end

get '/account/?' do
  if session['user_id'] == nil
    erb :'users/createaccount'
  else
    erb :'users/myaccount'
  end
end
