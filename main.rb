
require 'sinatra'
require 'sinatra/reloader'
require './models/user'
require './models/mentor'
require './models/meeting'
require './db_config'


get '/' do
  erb :index
end

get '/sign-up' do
  erb :signup
end

post '/users' do
  if params[:user_type] == "user"
    User.create(name: params[:user_name],email: params[:user_email], password: params[:user_password], city: params[:city], skills: params[:skills])
  elsif params[:user_type] == "mentor"
    Mentor.create(name: params[:user_name], email: params[:user_email], password: params[:user_password], city: params[:city], skills: params[:skills])
  end
redirect to "/"
end
