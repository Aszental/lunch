require 'active_record'

options = {
  adapter: 'postgresql',
  database: 'lunch'
}


ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']|| options)
