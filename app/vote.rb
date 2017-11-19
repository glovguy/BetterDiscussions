class Vote
  'it understands a users approval or disapproval of a card'
  attr_reader :card
  attr_reader :score

  def initialize(card, score)
    @card = card
    @score = score.to_i
  end

  def ==(other)
    @card == other.card && @score == other.score
  end

  def hash
    [@card, @score].hash
  end
end
