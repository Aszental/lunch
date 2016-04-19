
require 'sinatra'
require 'sinatra/reloader'
require './models/user'
require './models/mentor'
require './models/meeting'
require './db_config'
require 'pg'
require 'pony'



enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id]) || Mentor.find_by(id: session[:user_id])
  end


  def logged_in?
    !!current_user
  end

  def user_id
    current_user.id
  end

  def mentor?
    current_user.role == "Mentor"
  end

  def user?
    current_user.role == "User"
  end

end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  @lunches = Meeting.where(mentor_id: nil)
  @users = User.all
  erb :index
end

get '/sign-up' do
  erb :signup
end

post '/users' do
  # if params[:user_type] == "user"
    User.create(name: params[:user_name],email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills], role: params[:user_type])
  # elsif  == "mentor"
  #   Mentor.create(name: params[:user_name], email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills])
  # end
  redirect to "/"
end

get '/lunches' do
  # @lunches = Meeting.all
  @lunches = Meeting.where(mentor_id: nil)
  @users = User.all
  erb :lunches
end

post '/lunches' do

Meeting.create(location: params[:restaurant],city: params[:city], lunchdate: params[:date], user_id: user_id)

Pony.mail({
:from => params[:name],
   :to => 'amszental@gmail.com',
   :subject => "A new booking has been added!",
   :body => "#{params[:user_id]} has made a new booking in #{params[:city]}",
   :via => :smtp,
   :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => 'johnmann778@gmail.com',
    :password             => 'password18*',
    :authentication       => :plain,
    :domain               => "localhost.localdomain"
    }
   })


redirect to '/lunches'
end

get '/users/:id' do
  id = current_user.id.to_s
  @users = User.all
  if params[:id] == id
    if user?
      @lunch_display_open =  Meeting.where(user_id: params[:id], mentor_id: nil)
      @lunch_display_booked =  Meeting.where(user_id: params[:id]).where.not(mentor_id: nil)

    elsif mentor?
      @lunch_display_open =  Meeting.where(user_id: params[:id], mentor_id: nil)
      @lunch_display_booked =  Meeting.where(mentor_id: params[:id])
    end
  @user = User.find(params[:id])

  erb :user
else
  "Get Back You Are Not Welcome Here!"
end
end


get '/session/new' do
  erb :login
end

post '/session' do
  user = User.find_by(email: params[:email])
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
  # See if user is a mentor and logged in, if so updates the mentor ID to the current user
  if logged_in? && mentor?
    Meeting.update(params[:id], :mentor_id => current_user.id)
    redirect to '/'
  elsif user?
    "You are not a mentor"
  else
    redirect to '/sign-up'
  end
end


get '/lunches/new' do
  erb :newlunch
end
