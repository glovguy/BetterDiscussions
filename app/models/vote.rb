require_relative '../application_record.rb'
# it understands a users reaction to a card
class Vote < ApplicationRecord
  belongs_to :card
  belongs_to :user

  def ==(other)
    card == other.card && attitude == other.attitude
  end

  def hash
    [card, attitude].hash
  end

  def normalized_attitude
    (attitude + 1).to_f / 2.0
  end
end
