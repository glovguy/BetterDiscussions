class Post
  attr_reader :users, :cards
  def initialize(users=[], *cards)
    @users = users
    @cards = cards.flatten
  end

  def similar_users(user)
    other_users = @users.reject{|u| u==user}
    user_and_similarity_pairs = other_users.map { |u| [u, user.user_distance(u)] }
    Hash[*user_and_similarity_pairs.flatten]
  end

  def recommendations_hash(user, *cards)
    cards = @cards unless cards != []
    user_sims = similar_users(user)
    other_users = @users.reject{|u| u==user}
    pairs = cards.map do |c|
      similarity_sum = 0
      total_card_rec_score = other_users.inject(0) do |sum, u|
        value = (u.vote_on(c).score * user_sims[u])
        similarity_sum += user_sims[u] unless value == 0
        (u.vote_on(c).score * user_sims[u]) + sum
      end
      score = similarity_sum != 0 ? total_card_rec_score/similarity_sum : 0.0
      [c, Recommendation.new(total_card_rec_score, similarity_sum) ]
    end
    Hash[*pairs.flatten]
  end

  def recommendation_value_for_card(user, card)
    rec = recommendations_hash(user)[card]
    rec.value
  end

  def likelihood_of_pos_vote(user, card)
    recommendations_hash(user)[card].pos_vote_chance
  end
end

class Recommendation
  PRIOR_NUMER = 0.0
  PRIOR_DENOM = 1.0

  def initialize(score_sum, sim_sum)
    @score_sum = score_sum
    @sim_sum = sim_sum
  end

  def value(with_prior=false)
    return 0 unless @sim_sum != 0
    numer = @score_sum + (with_prior ? PRIOR_NUMER : 0.0)
    denom = @sim_sum + (with_prior ? PRIOR_DENOM : 0.0)
    numer / denom
  end

  def pos_vote_chance
    numer = (value(true)) + 1
    denom = 2.0
    numer / denom
  end
end
