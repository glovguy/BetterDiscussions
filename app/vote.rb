class Vote
  'it understands a users reaction to a card'
  attr_reader :card
  attr_reader :attitude

  def initialize(card, score)
    @card = card
    @attitude = Attitude.new(score)
  end

  def ==(other)
    @card == other.card && @attitude == other.attitude
  end

  def hash
    [@card, @attitude].hash
  end

  def to_f
    self.attitude.normalized
  end
end

class Attitude
  'it understands a preference modelled as an interval'
  def initialize(score, weight=1)
    @score = score.to_i
    @weight = weight
  end

  def ==(other)
    normalized == other.normalized
  end

  def hash
    @score.hash
  end

  def weigh(w)
    @weight = w
    self
  end

  def normalized
    (@score + 1) / 2.0
  end
end
