class Post
  attr_reader :users, :cards
  def initialize(users=[], *cards)
    @users = users
    @cards = cards.flatten
  end

  def similar_users(user)
    other_users = @users.reject{|u| u==user}
    pairs = other_users.map { |u| [u, user.user_distance(u)] }
    Hash[*pairs.flatten]
  end

  def card_recommendations(user)
    user_sims = similar_users(user)
    other_users = @users.reject{|u| u==user}
    # cards_not_voted = @cards.reject { |c| user.cards_voted.include? c }
    pairs = @cards.map do |c|
      similarity_sum = 0
      total_card_rec_score = other_users.inject(0) do |sum, u|
        value = (u.vote_on(c).score * user_sims[u])
        similarity_sum += user_sims[u] unless value == 0
        (u.vote_on(c).score * user_sims[u]) + sum
      end
      score = similarity_sum != 0 ? total_card_rec_score/similarity_sum : 0.0
      [c, score]
    end
    Hash[*pairs.flatten]
  end
end
