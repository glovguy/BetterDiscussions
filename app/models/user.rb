require_relative '../application_record.rb'
require_relative '../similarity.rb'
# it understands someone who interacts with content
class User < ApplicationRecord
  belongs_to :conversation
  has_many :votes
  has_many :cards, through: :votes
  has_many :conversations, through: :cards

  SIMILARITY_METRIC = Similarity::USER_DISTANCE

  def ==(other)
    username == other.username
  end

  def hash
    username.hash
  end

  def vote_for(card)
    votes.find { |v| v.card == card }
  end

  def similarity_with(other, exclude: [])
    SIMILARITY_METRIC.call(self, other, exclude)
  end

  def recommendation_for(user, card)
    return nil if common_cards_voted(user) == []
    sim = similarity_with(user)
    Recommendation.new(vote_for(card).normalized_attitude, sim)
  end

  def common_cards_voted(other)
    cards & other.cards
  end
end
