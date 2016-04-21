
require 'sinatra'
# require 'sinatra/reloader'
require './models/user'
require './models/mentor'
require './models/meeting'
require './models/message'
require './db_config'
require 'pg'
require 'pony'
require 'sinatra/flash'
require 'pry'
enable :sessions

helpers do


  def current_user
    User.find_by(id: session[:user_id])
  end


  def logged_in?
    !!current_user
  end

  def user_id
    current_user.id
  end

  def mentor?
    current_user.role == "mentor"
  end

  def user?
    current_user.role == "user"
  end

  def unread_message
    Message.where(receiverid: current_user.id.to_s).where(readstatus: FALSE).count
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
  @user = User.create(name: params[:user_name],email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills], role: params[:user_type], description: params[:description])
  if @user.valid?
  # elsif  == "mentor"
  #   Mentor.create(name: params[:user_name], email: params[:user_email], password: params[:password_digest], city: params[:city], skills: params[:skills])
  # end
  Pony.mail({
  :from => params[:name],
     :to => params[:user_email],
     :subject => "Thank you for Registering!",
     :body => "Thanks for Registering, you can view your profile by visiting here http://localhost:4567/users/#{User.last.id}",
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
     redirect to "/"

  else
    flash[:error] = "Your Email Already Exists!"
    redirect to "/sign-up"

end
end

get '/lunches' do
  # @lunches = Meeting.all
  if params[:date] && params[:city] == ""
    @lunches = Meeting.where(mentor_id: nil).where('lunchdate = ?', params[:date])
    @users = User.all
    erb :lunches
  elsif params[:city] && params[:date] == ""
    @lunches = Meeting.where(mentor_id: nil).where(city: params[:city])
    @users = User.all
    erb :lunches
  elsif params[:city] && params[:date]
    @lunches = Meeting.where(mentor_id: nil).where(city: params[:city]).where('lunchdate = ?', params[:date])
    @users = User.all
    erb :lunches

  else
    @lunches = Meeting.where(mentor_id: nil)
    @users = User.all
    erb :lunches
  end
end

post '/lunches' do

Meeting.create(location: params[:restaurant],city: params[:city], lunchdate: params[:date], user_id: user_id, description: params[:description])

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
      @lunch_display_open =  Meeting.order(:lunchdate).where(user_id: params[:id], mentor_id: nil).where.not('lunchdate < ?', DateTime.now)
      @lunch_display_booked =  Meeting.order(:lunchdate).where(user_id: params[:id]).where.not(mentor_id: nil)
      @lunch_display_past = Meeting.order(:lunchdate).where(user_id: params[:id]).where('lunchdate < ?', DateTime.now)
    elsif mentor?
      @lunch_display_open =  Meeting.order(:lunchdate).where(user_id: params[:id], mentor_id: nil).where.not('lunchdate < ?', DateTime.now)
      @lunch_display_booked =  Meeting.order(:lunchdate).where(mentor_id: params[:id])
      @lunch_display_past = Meeting.order(:lunchdate).where(mentor_id: params[:id]).where('lunchdate < ?', DateTime.now)
    end
  @user = User.find(params[:id])

  erb :user
else
  "Get Back You Are Not Welcome Here!"
end
end


patch '/users/:id' do

  # sql = "UPDATE dishes SET name ='#{params[:name]}', image_url ='#{params[:image_url]}' WHERE id = #{params[:id]}"
  # run_sql(sql)
  edit_user = User.find(params[:id])
  edit_user.name = params[:name]
  edit_user.description = params[:desc]
  edit_user.save
  redirect to "/users/#{params[:id]}"
end

# put '/message/read' do
#   @messages = Message.all
#   @messages.each do |x|
#     if current_user.id == x.receiverid.to_i
#       x.readstatus = TRUE
#       x.save
#     end
#   end
#   redirect back
# end

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
    flash[:error] = "Your login Details are incorrect"
    redirect to '/'

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
    redirect to '/success'
  elsif logged_in? && user?
    "You are not a mentor"
  else
    redirect to '/sign-up'
  end
end


get '/lunches/new' do
  if user?
  erb :newlunch
  else
  return "You cannot book as a mentor"
  end

end

get '/lunches/:id' do
  @users = User.all
  @lunch = Meeting.find(params[:id])
  if @lunch.mentor_id == nil
    erb :lunch
  else
    "This lunch is no longer available to be booked"
  end
end

get '/success' do
  "Your Booking is Successful!"
end

get '/lunch/:id/messages' do
  @messages = Message.where(meetingid: params[:id])
  @users = User.all
  @messages.each do |x|
    if current_user.id == x.receiverid.to_i
      x.readstatus = TRUE
      x.save
    end
  end

  erb :messages
end

post '/lunch/:id/messages' do
    @users = User.all
    @meetings = Meeting.all
    send_id = current_user.id
    if mentor?
      @receiverid = @meetings.find(params[:id]).user_id
    elsif user?
      @receiverid = @meetings.find(params[:id]).mentor_id
    end
    Message.create(body: params[:body], senderid: send_id, receiverid: @receiverid, meetingid: params[:id], timestamp: Time.now, readstatus: FALSE)
    redirect back
  end
