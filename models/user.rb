require 'active_record'
require 'pry'
require 'gravtastic'

class User < ActiveRecord::Base
  has_many :mentors, through: :meetings
  has_many :meetings
  has_secure_password
end
