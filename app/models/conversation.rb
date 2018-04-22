require 'statistics2'
require_relative './recommendation.rb'
require_relative '../application_record.rb'

ENTROPY = lambda do |prob|
  return (-prob * (Math.log(prob) / Math.log(2))).abs
end

TOTAL_ENTROPY = lambda do |prob|
  return (-prob * Math.log2(prob) - (1.0 - prob) * Math.log2(1.0 - prob)).abs
end

# it understands a group of cards that are compared to each other
class Conversation < ApplicationRecord
  has_many :cards
  has_many :users, through: :cards

  PRIOR = Recommendation.new(0, 1)

  # Faster than active record association
  def users
    cards.map(&:votes).flatten.map(&:user)
  end

  def recommendation_for(user, card)
    other_users = users.reject { |u| u.vote_for(card).nil? }.uniq - [user]
    other_users.inject(nil) do |sum, u|
      rec = u.recommendation_for(user, card)
      return sum if rec.nil?
      rec + sum
    end
  end

  def vote_entropy(user, vote)
    recommendation = recommendation_for(user, vote.card)
    return 1 unless recommendation
    ENTROPY.call(recommendation.likelihood_of(vote.attitude)).to_f
  end
end
