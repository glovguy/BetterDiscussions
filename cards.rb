
class Vote
  attr_reader :card
  attr_reader :score

  def initialize(card, score)
    @card = card
    @score = score.to_i
  end

  def eql? other
    @card == other.card && @score == other.score
  end

  def hash
    [@card, @score].hash
  end
end

class Card
  attr_reader :body

  def initialize(body)
    @body = body.to_s
    @replies = []
  end

  def eql? other
    @body == other.body
  end

  def hash
    @body.hash
  end
end

class User
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

  def similarity_with(other)
    user_distance(other)
  end

  def recommendation_for(user, card)
    return nil if self.common_cards_voted(user) == []
    sim = similarity_with(user)
    Recommendation.new(vote_on(card).score * sim, sim)
  end

  def common_cards_voted(other)
    self.cards_voted & other.cards_voted
  end

  def user_distance(other, exclude=[])
    common_cards = self.common_cards_voted(other) - exclude
    return 0 if common_cards == []
    total = common_cards.inject(0) do |sum, card|
      ( self.vote_on(card).score - other.vote_on(card).score ) ** 2 + sum
    end
    final = 1.0/(Math.sqrt(total)+1)
  end

  def pearson_score(other)
    common_cards = self.common_cards_voted(other)
    return 0 if common_cards == []

    sum1 = common_cards.inject(0) { |sum, card| sum + self.vote_on(card).score }
    sum2 = common_cards.inject(0) { |sum, card| sum + other.vote_on(card).score }

    sumSq1 = common_cards.inject(0) { |sum, card| sum + (self.vote_on(card).score) ** 2 }
    sumSq2 = common_cards.inject(0) { |sum, card| sum + (other.vote_on(card).score) ** 2 }

    pSum = common_cards.inject(0) { |sum, card| sum + (self.vote_on(card).score * other.vote_on(card).score) }

    numer = pSum - (sum1*sum2/common_cards.length)
    denom = Math.sqrt((sumSq1 - sum1**2 / common_cards.length) * (sumSq2 - sum2**2 / common_cards.length))
    return 0 if denom == 0
    numer / denom
  end
end

class Recommendation
  attr_reader :score_sum
  attr_reader :sim_sum
  protected :score_sum
  protected :sim_sum

  def initialize(score_sum, sim_sum)
    @score_sum = score_sum
    @sim_sum = sim_sum
  end

  def +(other)
    return self unless other.class == Recommendation
    Recommendation.new(@score_sum + other.score_sum, @sim_sum + other.sim_sum)
  end

  def weighted_prediction
    return 0 unless @sim_sum != 0
    @score_sum / @sim_sum
  end

  def pos_vote_chance
    numer = (weighted_prediction) + 1
    denom = 2.0
    numer / denom
  end

  def neg_vote_chance
    1 - pos_vote_chance
  end
end
