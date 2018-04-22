module Similarity
  USER_DISTANCE = lambda do |user1, user2, exclude = []|
    common_cards = user1.common_cards_voted(user2) - exclude
    return 0 if common_cards == []
    total = common_cards.inject(0) do |sum, card|
      norm_diff = user1.vote_for(card).normalized_attitude -
                  user2.vote_for(card).normalized_attitude
      sum + norm_diff.to_f**2
    end
    1.0 / (Math.sqrt(total) + 1)
  end

  PEARSON_SCORE = lambda do |user1, user2, exclude = []|
    common_cards = user1.common_cards_voted(user2) - exclude
    return 0 if common_cards == []

    sum1 = common_cards.inject(0) do |sum, card|
      sum + user1.vote_for(card).normalized_attitude
    end.to_f
    sum2 = common_cards.inject(0) do |sum, card|
      sum + user2.vote_for(card).normalized_attitude
    end.to_f

    sum_sq1 = common_cards.inject(0) do |sum, card|
      sum + user1.vote_for(card).normalized_attitude**2
    end
    sum_sq2 = common_cards.inject(0) do |sum, card|
      sum + user2.vote_for(card).normalized_attitude**2
    end

    p_sum = common_cards.inject(0) do |sum, card|
      sum + (user1.vote_for(card).normalized_attitude *
        user2.vote_for(card).normalized_attitude)
    end

    numer = p_sum - (sum1 * sum2 / common_cards.length)
    denom = Math.sqrt(
      (sum_sq1 - sum1**2 / common_cards.length) *
      (sum_sq2 - sum2**2 / common_cards.length)
    )
    return 0 if denom.zero?
    (numer.to_f / denom)
  end
end
