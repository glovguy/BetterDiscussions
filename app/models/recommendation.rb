# require_relative '../application_record.rb'
# require_relative './attitude.rb'
# it understands a vote prediction that a user would have on a card
class Recommendation # < ApplicationRecord
  attr_reader :normalized_attitude
  attr_reader :similarity_sum

  def initialize(normalized_attitude, similarity_sum)
    # normalized_attitude =  (attitude + 1) / 2.0
    @normalized_attitude = (normalized_attitude * similarity_sum).to_f
    @similarity_sum = similarity_sum.to_f
  end

  def +(other)
    return self unless other.class == Recommendation
    @normalized_attitude += other.normalized_attitude
    @similarity_sum += other.similarity_sum
    self
  end

  def weighted_prediction
    return 0 if @similarity_sum.zero?
    sim_sum = @similarity_sum.to_f
    @normalized_attitude.to_f / sim_sum
  end

  # (@score + 1) / 2.0

  def likelihood_of(normalized_attitude)
    # normalized_attitude =  (attitude + 1) / 2.0
    1 - (weighted_prediction - normalized_attitude).abs
  end

  # def normalize(attitude)
  #   (attitude + 1) / 2.0
  # end
end
