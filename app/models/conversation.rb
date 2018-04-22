require 'statistics2'
require_relative './recommendation.rb'

ENTROPY = lambda do |prob|
  return (-prob * (Math.log(prob) / Math.log(2))).abs
end

TOTAL_ENTROPY = lambda do |prob|
  return (-prob * Math.log2(prob) - (1.0 - prob) * Math.log2(1.0 - prob)).abs
end

# it understands a group of cards that are compared to each other
module Conversation

  PRIOR = Recommendation.new(0, 1)

  def self.recommendation_for(user, card)
    other_users = card.users - [user]
    other_users.inject(nil) do |sum, u|
      rec = u.recommendation_for(user, card)
      return sum if rec.nil?
      rec + sum
    end
  end

  def self.vote_entropy(user, vote)
    recommendation = recommendation_for(user, vote.card)
    return 1 unless recommendation
    ENTROPY.call(recommendation.likelihood_of(vote.attitude)).to_f
  end
end
