# it understands a vote prediction that a user would have on a card
class Recommendation
  attr_reader :attitude
  attr_reader :similarity_sum
  protected :attitude
  protected :similarity_sum

  def initialize(attitude, similarity_sum)
    @attitude = attitude.normalized * similarity_sum
    @similarity_sum = similarity_sum
  end

  def +(other)
    return self unless other.class == Recommendation
    @attitude += other.attitude
    @similarity_sum += other.similarity_sum
    self
  end

  def weighted_prediction
    return 0 if @similarity_sum.zero?
    @attitude / @similarity_sum # /
  end

  def likelihood_of(attitude)
    1 - (weighted_prediction - attitude.normalized).abs
  end
end
