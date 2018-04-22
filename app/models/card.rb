require_relative '../application_record.rb'
# it understands content that can be voted on
class Card < ApplicationRecord
  belongs_to :conversation
  has_many :votes
  has_many :users, through: :votes

  def ==(other)
    body == other.body
  end

  def hash
    body.hash
  end

  def to_s
    'CARD_' + body
  end
end
