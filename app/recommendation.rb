class Recommendation
  'it understands a vote prediction that user would have on a card'
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
