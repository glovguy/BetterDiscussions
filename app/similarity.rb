module Similarity
  USER_DISTANCE = lambda do |user1, user2, exclude=[]|
    common_cards = user1.common_cards_voted(user2) - exclude
    return 0 if common_cards == []
    total = common_cards.inject(0) do |sum, card|
      ( user1.vote_on(card).score - user2.vote_on(card).score ) ** 2 + sum
    end
    final = 1.0/(Math.sqrt(total)+1)
  end

  PEARSON_SCORE = lambda do |user1, user2, exclude=[]|
    common_cards = user1.common_cards_voted(user2) - exclude
    return 0 if common_cards == []

    sum1 = common_cards.inject(0) { |sum, card| sum + user1.vote_on(card).score }
    sum2 = common_cards.inject(0) { |sum, card| sum + user2.vote_on(card).score }

    sumSq1 = common_cards.inject(0) { |sum, card| sum + (user1.vote_on(card).score) ** 2 }
    sumSq2 = common_cards.inject(0) { |sum, card| sum + (user2.vote_on(card).score) ** 2 }

    pSum = common_cards.inject(0) do |sum, card|
      sum + (user1.vote_on(card).score * user2.vote_on(card).score)
    end

    numer = pSum - (sum1*sum2/common_cards.length)
    denom = Math.sqrt(
      (sumSq1 - sum1**2 / common_cards.length) *
      (sumSq2 - sum2**2 / common_cards.length)
      )
    return 0 if denom.zero?
    numer / denom
  end
end
