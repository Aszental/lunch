require 'active_record'
require 'pry'

class Meeting < ActiveRecord::Base
  belongs_to :mentors
  belongs_to :meetings
end
