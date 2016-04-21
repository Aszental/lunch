require 'active_record'

class Mentor < ActiveRecord::Base
  has_many :users, through: :meetings
  has_many :meetings
  has_secure_password
end
