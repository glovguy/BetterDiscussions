SIMILARITY_METRIC = Similarity::USER_DISTANCE

class User
  'it understands someone who interacts with content'
  attr_reader :username

  def initialize(username, *votes)
    @username = username.to_s
    @votes = votes
  end

  def eql? other
    @username == other.username
  end

  def hash
    @username.hash
  end

  def add_vote(vote)
    @votes << vote
  end

  def cards_voted
    @votes.map { |v| v.card }
  end

  def vote_on(card)
    @votes.find { |v| v.card == card }
  end

  def similarity_with(other, exclude=[])
    SIMILARITY_METRIC.call(self, other, exclude)
  end

  def recommendation_for(user, card)
    return nil if self.common_cards_voted(user) == []
    sim = similarity_with(user)
    Recommendation.new(vote_on(card).score * sim, sim)
  end

  def common_cards_voted(other)
    self.cards_voted & other.cards_voted
  end
end
