
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
    sim = similarity_with(user)
    Recommendation.new(vote_on(card).score * sim, sim)
  end

  def common_cards_voted(other)
    self.cards_voted & other.cards_voted
  end

  def user_distance(other)
    total = self.common_cards_voted(other).inject(0) do |sum, card|
      ( self.vote_on(card).score - other.vote_on(card).score ) ** 2 + sum
    end
    final = 1.0/(Math.sqrt(total)+1)
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

def pearson_score(u1, u2)
  all_keys = u1.keys & u2.keys
  u1 = u1.select { |i, o| all_keys.include? i }
  u2 = u2.select { |i, o| all_keys.include? i }

  sum1 = u1.reduce(:+)
  sum2 = u2.reduce(:+)

  sumSq1 = u1.inject(0) { |sum, n| n**2 + sum }
  sumSq2 = u2.inject(0) { |sum, n| n**2 + sum }

  pSum = (u1+u2)

  num = 0
end


