
require 'sinatra'
require 'sinatra/reloader'
require './models/user'
require './models/mentor'
require './models/meeting'
require './db_config'
require 'pg'


enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id]) || Mentor.find_by(id: session[:user_id])
  end


  def logged_in?
    !!current_user

    # if current_user
    #   return true
    # else
    #   return false
    # end
  end

end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  erb :index
end

get '/sign-up' do
  erb :signup
end

post '/users' do
  if params[:user_type] == "user"
    User.create(name: params[:user_name],email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills])
  elsif params[:user_type] == "mentor"
    Mentor.create(name: params[:user_name], email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills])
  end
  redirect to "/"
end

get '/lunches' do
  # @lunches = Meeting.all
  @lunches = Meeting.where(mentor_id: nil)
  @users = User.all
  erb :lunches
end

get '/user/:id' do
  id = current_user.id.to_s
  binding.pry
  if current_user.id.to_i == id
    @user = User.find(params[:id])
    erb :user
  else
    "THIS IS THE WRONG USER"
  end
end



get '/session/new' do
  erb :login
end

post '/session' do
  user = User.find_by(email: params[:email]) ||   user = Mentor.find_by(email: params[:email])

  if user && user.authenticate(params[:password])
    # we're in! create a new session
    session[:user_id] = user.id
    # redirect

    redirect to '/'
  else
    # stay at the login form
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect to '/'

end



post '/book/:id' do
  if logged_in? && current_user.class == Mentor
    Meeting.update(params[:id], :mentor_id => current_user.id)
    redirect to '/'
  else
    redirect to '/sign-up'
  end
end
