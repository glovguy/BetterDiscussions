require "statistics2"
require_relative "cards.rb"

class Conversation
  attr_reader :users, :cards

  PRIOR = Recommendation.new(0, 1)

  def initialize(users=[], *cards)
    @users = users
    @cards = cards.flatten
  end

  def recommendation_for(user, card)
    other_users = @users.reject{|u| u==user || u.vote_on(card).nil? }
    other_users.inject(nil) { |sum, u| u.recommendation_for(user, card) + sum }
  end

  def likelihood_of_pos_vote(user, card)
    (PRIOR + recommendation_for(user, card)).pos_vote_chance
  end

  def chi_squared_likelihood(card)
    users_who_voted = @users.select do |u|
      u.vote_on(card).score != 0
    end
    chi_sqr_stat = users_who_voted.inject(0) do |sum, u|
      pred = recommendation_value_for_card(u, card)
      numer = (u.vote_on(card).score - pred) ** 2
      denom = pred
    end
    likelihood = Statistics2.chi2dist(1, chi_sqr_stat)
    # puts 'Likelihood: ' + likelihood.to_s + " for:\t\t " + card.body
    likelihood
  end

  def card_entropy(card)
    users_who_voted = @users.select do |u|
      u.vote_on(card) != 0
    end
    entropy = users_who_voted.inject(0) do |sum, u|
      card_prob = likelihood_of_pos_vote(u, card)
      -card_prob * Math.log2(card_prob) + sum
    end
    # puts 'card: ' + card.body
    # puts 'entropy: ' + entropy.to_s
    entropy
  end
end
