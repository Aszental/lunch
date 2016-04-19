require 'active_record'
require 'pry'

class Mentor < ActiveRecord::Base
  has_many :users, through: :meetings
  has_many :meetings
  has_secure_password
end
