# it understands a vote prediction that a user would have on a card
class Recommendation
  attr_reader :weighted_normalized_attitude
  attr_reader :similarity_sum

  def initialize(normalized_attitude, similarity_sum)
    @weighted_normalized_attitude = (normalized_attitude.to_f * similarity_sum)
    @similarity_sum = similarity_sum
  end

  def +(other)
    return self unless other.class == Recommendation
    @weighted_normalized_attitude += other.weighted_normalized_attitude
    @similarity_sum += other.similarity_sum
    self
  end

  def weighted_prediction
    return 0 if @similarity_sum.zero?
    sim_sum = @similarity_sum
    (@weighted_normalized_attitude.to_f / sim_sum)
  end

  def likelihood_of(normalized_attitude)
    return 0 if @similarity_sum.zero?
    1 - (weighted_prediction - normalized_attitude).abs
  end
end
