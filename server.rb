require 'sinatra'
require 'sinatra/activerecord'

enable :sessions

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  set :database, {adapter: "sqlite3", database: "database.sqlite3"}
end

class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy
end

class Post < ActiveRecord::Base
  belongs_to :user
end

before ['/posts','/posts/:id','/account/?','/post'] do
  if session['user_id'] == nil
    redirect '/'
  end
end

get '/' do
  if session['user_id'] != nil
    if params[:offset] == nil
      @posts = Post.all.order(created_at: :desc).limit(20)
    else
      @posts = Post.all.order(created_at: :desc).limit(20).offset(params[:offset])
    end
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
      @user = User.new(email: params[:email], username: params[:email], first_name: params[:first_name].capitalize, last_name: params[:last_name].capitalize, password: params[:password], birthdate: params[:birthdate])
      @user.save
      session['user_id'] = @user.id
      redirect '/'
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
      @error = "Invalid Password"
    end
  else
    @error = "User email not found"
  end
  erb :'users/login'
end

get '/post/delete/:id' do
  @post = Post.find(params[:id])
  if session['user_id'] == @post.user_id
    @post.delete
  end
  redirect '/posts'
end

get '/post/update/:id' do
  @post = Post.find(params[:id])
  if session['user_id'] == @post.user_id
    erb :'posts/update'
  else
    redirect '/posts'
  end
end

post '/post/update/:id' do
  @post = Post.find(params[:id])
  if session['user_id'] == @post.user_id
    @post.title = params['title']
    @post.content = params['content']
    @post.save
    redirect '/posts'
  else
    redirect '/posts'
  end
end

get '/post' do
  erb :'/post'
end

get '/posts/:id' do
  @posts = Post.where(user_id: params['id']).order(created_at: :desc).limit(20).to_a
  erb :'posts/posts'
end

get '/posts' do
  @posts = Post.where(user_id: session['user_id']).order(created_at: :desc).limit(20).to_a
  erb :'posts/posts'
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
      @user.first_name = params[:first_name].capitalize
      @user.last_name = params[:last_name].capitalize
      @user.save
      @success = "Changes made successfully"
      if params[:new_password] != ""
        if params[:new_password].length>=8
          @user.password = params[:new_password]
          @user.save
          @success = "Changes made successfully"
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

post '/deleteacc' do
  @user = User.find(session['user_id'])
  if @user != nil
    if params[:deleteAcc] == @user.password
      @user.destroy
      @user.save
      session['user_id'] = nil
      redirect '/'
    else
      @error = "Incorrect Password Entered. Account still Extant"
      erb :'users/myaccount'
    end
  end
end
