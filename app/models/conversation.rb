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

  PRIOR = Recommendation.new(0, 1)

  # def initialize(users = [], *cards)
  #   @users = users
  #   @cards = cards.flatten
  # end

  def users # I'd like to tidy this up into something from active record
    cards.map {|c| c.votes}.flatten.map {|v| v.user}.uniq
  end

  def recommendation_for(user, card)
    other_users = users
    other_users.inject(nil) do |sum, u|
      return sum if u.recommendation_for(user, card).nil?
      u.recommendation_for(user, card) + sum
    end
  end

  def vote_entropy(user, vote)
    recommendation = recommendation_for(user, vote.card)
    return 1 unless recommendation
    ENTROPY.call(recommendation.likelihood_of(vote.attitude))
  end
end
