require 'active_record'
require 'pry'

class User < ActiveRecord::Base
  has_many :meetings
  has_many :mentors through :meetings
end
