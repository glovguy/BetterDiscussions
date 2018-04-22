require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :cards, force: true do |t|
    t.string :body
    t.references :conversation
  end
  create_table :conversations, force: true do |t|
    t.string :name
  end
  create_table :users, force: true do |t|
    t.string :username
  end
  create_table :votes, force: true do |t|
    t.references :card
    t.references :user
    t.decimal :attitude
  end
end
