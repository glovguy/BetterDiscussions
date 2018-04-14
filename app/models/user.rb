# it understands someone who interacts with content
class User
  attr_reader :username

  SIMILARITY_METRIC = Similarity::USER_DISTANCE

  def initialize(username, *votes)
    @username = username.to_s
    @votes = votes
  end

  def ==(other)
    @username == other.username
  end

  def hash
    @username.hash
  end

  def add_vote(vote)
    @votes << vote
  end

  def cards_voted
    @votes.map(&:card)
  end

  def vote_for(card)
    @votes.find { |v| v.card == card }
  end

  def similarity_with(other, exclude = [])
    SIMILARITY_METRIC.call(self, other, exclude)
  end

  def recommendation_for(user, card)
    return nil if common_cards_voted(user) == []
    sim = similarity_with(user)
    Recommendation.new(vote_for(card).attitude, sim)
  end

  def common_cards_voted(other)
    cards_voted & other.cards_voted
  end
end
