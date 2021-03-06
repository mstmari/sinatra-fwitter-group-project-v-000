require './config/environment'

class ApplicationController < Sinatra::Base
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "secret"
  end

get '/' do
  if session[:user_id]
     redirect '/tweets'
   end
  erb :index

end

get '/signup' do
if session[:user_id]
   redirect '/tweets'
 end
  erb :'users/create_user'
end

get '/login' do
  if session[:user_id]
     redirect '/tweets'
   end
  erb :'users/login'
end



post '/login' do
  @user = User.find_by(:username => params[:username])
  if @user && @user.authenticate(params[:password])
  session[:user_id]= @user.id
  redirect '/tweets'
else
  redirect '/login'
end
end


get '/users/:id' do
  @current_user = User.find_by(:username => params[:captures])
  erb :'/users/show'
end

get '/tweets/new' do
if  !is_logged_in?
  redirect '/login'
else
  erb :'tweets/create_tweet'
end
end

get '/tweets/:id' do
  if  !is_logged_in?
    redirect '/login'
  else
    @tweet = Tweet.find_by_id(params[:id])
    erb :'/tweets/show_tweet'
  end
end

get '/tweets/:id/edit' do
  if  !is_logged_in?
    redirect '/login'
  else
    @tweet = Tweet.find_by_id(params[:id])
    erb :'/tweets/edit_tweet'
  end
end


patch '/tweets/:id' do
if
  !is_logged_in?
    redirect '/login'

else
  @tweet = Tweet.find(params[:id])
    if @tweet.content.empty?
    redirect "/tweets/#{@tweet.id}/edit"
  end
  @tweet.update(content: params[:content])
  @tweet.save
  redirect "/tweets/#{@tweet.id}/edit"

end
end






post '/tweets/new' do
  is_logged_in?

  if params[:content].empty?
    redirect '/tweets/new'
  else @tweet = Tweet.create(params)
  end
  @current_user.tweets << @tweet

  redirect '/tweets'
end


post '/signup' do

  if params[:username].empty?
     redirect '/signup'

    elsif params[:email].empty?
      redirect '/signup'

    elsif params[:password].empty?
      redirect '/signup'

    else @current_user = User.create(params)
      session[:user_id]= @current_user.id
      redirect '/tweets'

    end
end

get '/logout' do
  if is_logged_in?
  session.clear
  redirect '/login'
else
  redirect '/'
end
end

delete '/tweets/:id/delete' do
if
    !is_logged_in?
    redirect '/login'
else
  @tweet = Tweet.find_by_id(params[:id])
  @tweet.destroy if @tweet.user == current_user
  redirect '/tweets'
end
end

#<----------helpers-------->


helpers do



  def current_user
    if session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end
end

  def is_logged_in?
    !!current_user
  end
end

end
