require 'active_record'
require 'pry'

class Meeting < ActiveRecord::Base
  belongs_to :users
  belongs_to :mentors
end
