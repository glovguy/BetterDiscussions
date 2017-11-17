require "statistics2"
require_relative './recommendation.rb'

class Conversation
  'it understands a collection of related cards'
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

  def likelihood_of_neg_vote(user, card)
    1 - likelihood_of_pos_vote(user, card)
  end

  def chi_squared_likelihood(card)
    users_who_voted = @users.reject do |u|
      u.vote_on(card).nil?
    end
    return nil unless users_who_voted.length > 1
    table_sums = users_who_voted.inject({'pred'=>0,'obs'=>0}) do |sum, u|
      sum['pred'] += likelihood_of_pos_vote(u, card)
      sum['obs'] += u.vote_on(card).score
      sum
    end
    chi_sqr_stat = ( (table_sums['obs'] - table_sums['pred']) ** 2 ) / table_sums['pred']
    Statistics2.chi2dist(1, chi_sqr_stat)
  end

  def card_entropy(card)
    users_who_voted = @users.select do |u|
      u.vote_on(card) != 0
    end
    users_who_voted.inject(0) do |sum, u|
      card_prob = likelihood_of_pos_vote(u, card)
      -card_prob * Math.log2(card_prob) + sum
    end
  end
end
