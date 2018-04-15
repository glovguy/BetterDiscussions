# Instead of loading all of Rails, load the
# particular Rails dependencies we need
require 'sqlite3'
require 'active_record'

# Set up a database that resides in RAM
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Set up database tables and columns
ActiveRecord::Schema.define do
  # create_table :attitudes, force: true do |t|
  #   t.decimal :score
  #   t.decimal :weight, column_options: { null: 1 }
  # end
  create_table :cards, force: true do |t|
    t.string :body
    t.references :conversation
  end
  create_table :conversations, force: true do |t|
    t.string :name
  end
  # create_table :recommendations, force: true do |t|
  #   t.decimal :similarity_sum
  #   t.references :attitude
  # end
  create_table :users, force: true do |t|
    t.string :username
    # t.references :conversation
  end
  create_table :votes, force: true do |t|
    t.references :card
    t.references :user
    t.decimal :attitude
  end
end

# Set up model classes

# class Owner < ApplicationRecord
#   has_many :pets
# end
# class Pet < ApplicationRecord
#   belongs_to :owner
# end
