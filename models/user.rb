require 'active_record'
require 'gravtastic'

class User < ActiveRecord::Base
  has_many :mentors, through: :meetings
  has_many :meetings
  validates :email, uniqueness: true, presence: true
  has_secure_password
end
