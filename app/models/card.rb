require_relative '../application_record.rb'
# it understands content that can be voted on
class Card < ApplicationRecord
  belongs_to :conversation
  has_many :votes

  def self.cards_for_user(user)
    votes = user.votes
    votes.map { |v| v.card }.uniq { |c| c.id }
  end

  # def initialize(body)
  #   @body = body.to_s
  # end

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
