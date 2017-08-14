
class Vote
  attr_reader :card
  attr_reader :score

  def initialize(card, score)
    @card = card
    @score = score
  end
end

class Card
  attr_reader :body

  def initialize(user, body)
    @user = user
    @body = body
    @replies = []
  end
end

class User
  attr_reader :username

  def initialize(username, *votes)
    @username = username
    @votes = votes
  end

  def cards_voted
    @votes.map { |v| v.card }
  end

  def vote_on(card)
    @votes.find(Proc.new {Vote.new(card, 0)}) { |v| v.card == card }
  end

  def user_distance(other)
    cards_both_voted = self.cards_voted & other.cards_voted
    total = cards_both_voted.inject(0) do |sum, card|
      ( self.vote_on(card).score - other.vote_on(card).score ) ** 2 + sum
    end
    final = 1.0/(Math.sqrt(total)+1)
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


