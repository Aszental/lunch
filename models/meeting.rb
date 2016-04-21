require 'active_record'

class Meeting < ActiveRecord::Base
  belongs_to :users
  belongs_to :mentors



end
