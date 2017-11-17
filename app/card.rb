class Card
  'it understands content that can be voted on'
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

  def to_s
    'CARD_' + body
  end
end
