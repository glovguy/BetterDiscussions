require 'minitest/autorun'
require_relative './cards.rb'
require_relative './conversations.rb'
require_relative './test_setup.rb'

class CardTests < Minitest::Test
  def test_card_equality
    assert(Card.new('body').eql? Card.new('body'))
  end

  def test_card_hash_equality
    assert_equal(Card.new('body').hash, Card.new('body').hash)
  end

  def test_user_equality
    assert(User.new('bane').eql? User.new('bane'))
  end

  def test_user_hash_equality
    assert_equal(User.new('bane').hash, User.new('bane').hash)
  end

  def test_vote_equality
    assert(Vote.new(CARD1,-1).eql? Vote.new(CARD1, -1))
  end

  def test_vote_hash_equality
    assert_equal(Vote.new(CARD1, -1).hash, Vote.new(CARD1, -1).hash)
  end

  def test_user_can_have_vote
    card1 = Card.new(Object.new)
    vote1 = Vote.new(card1, 0)
    user1 = User.new('test')
    assert_equal(false, user1.cards_voted.include?(card1))
    user1.add_vote(vote1)
    assert(user1.cards_voted.include? card1)
  end

  def test_user_distance_equality
    assert_equal(
      SUE.user_distance(ROBERT),
      ROBERT.user_distance(SUE)
      )
  end

  def test_user_distance_greater_than
    assert(
      SUE.user_distance(ROBERT) >
        JAN.user_distance(ROBERT)
      )
  end

  def test_distance_range
    CONVO1.users.each do |u|
      dist = u.user_distance(ROBERT)
      assert(dist >= 0.0)
      assert(dist <= 1.0)
    end
  end

  def test_distance_with_self
    assert_equal(SUE.user_distance(SUE), 1.0)
  end

  def test_distance_totally_unrelated_user
    assert_equal(ALICE.user_distance(USER_WITH_NO_VOTES), 0.0)
  end

  def test_distance_excluding
    assert_equal(ALICE.user_distance(BOB), 0.3333333333333333)
    assert_equal(ALICE.user_distance(BOB, exclude=[CARD2]), 1.0)
    assert_equal(ALICE.user_distance(BOB, exclude=[CARD1,CARD2]), 0.0)
  end

  def test_pearson_score_range
    CONVO1.users.each do |u1|
      CONVO1.users.each do |u2|
        dist = u1.pearson_score(u2)
        assert(dist >= -1.0)
        assert(dist <= 1.0)
      end
    end
  end

  def test_vote_converts_score_to_integer
    vote1 = Vote.new(CARD1, '-1')
    refute_equal(vote1.score.class, String)
  end

  def test_recommendation_adding
    rec1 = Recommendation.new(1, 2)
    rec2 = Recommendation.new(2, 4)
    combined_rec = rec1 + rec2
    assert_equal(
      combined_rec.weighted_prediction,
      Recommendation.new(3, 6).weighted_prediction
      )
  end

  def test_recommendations
    rec1 = Recommendation.new(1.0, 1.0)
    rec2 = Recommendation.new(4.5, 6.0)
    assert_equal(rec1.weighted_prediction, 1.0)
    assert_equal(rec2.weighted_prediction, 0.75)
  end

  def test_recommendation_for_totally_unrelated_user
    assert_nil(ALICE.recommendation_for(USER_WITH_NO_VOTES, CARD1))
  end

  def test_recommendation_pos_vote_chance
    rec1 = Recommendation.new(0, 1)
    rec2 = Recommendation.new(4.5, 6)
    assert_equal(rec1.pos_vote_chance, 0.5)
  end

  def test_likelihood_of_pos_vote_range
    likelihoods = CONVO1.cards.map { |c| CONVO1.likelihood_of_pos_vote(PHIL, c) }
    likelihoods.each do |l|
      assert(l >= 0)
      assert(l <= 1)
    end
  end

  def test_pos_vote_and_neg_vote_eql_one
    likelihoods = CONVO1.cards.map do |c|
      [CONVO1.likelihood_of_pos_vote(PHIL, c), CONVO1.likelihood_of_neg_vote(PHIL, c)]
    end.flatten
    likelihoods.each_slice(2) do |l|
      assert_equal(l[0] + l[1], 1)
    end
  end
end

class ConversationTests < Minitest::Test
  def test_recommendation_for
    assert(CONVO1.recommendation_for(SUE, CARD5).weighted_prediction < 0)
    assert(CONVO1.recommendation_for(SUE, CARD6).weighted_prediction > 0)
    assert(CONVO1.recommendation_for(SUE, CARD7).weighted_prediction < 0)
    assert_equal(CONVO1.recommendation_for(SUE, CARD8).weighted_prediction, 1)
  end

  def test_card_recommendation_range
    CONVO1.users.each do |u|
      assert(CONVO1.recommendation_for(u, CARD1).weighted_prediction >= -1)
      assert(CONVO1.recommendation_for(u, CARD1).weighted_prediction <= 1)
    end
  end

  def test_card_without_votes_returns_nil
    assert_nil(CONVO1.recommendation_for ROBERT, CARD_NO_ONE_HAS_VOTED_ON)
  end

  def test_card_user_has_voted_on_is_given_recommendation
    assert_equal(CONVO1.recommendation_for(ROBERT, CARD1).weighted_prediction, 0.057190958417936644)
  end

  def test_chi_squared_likelihood
    cards = [CARD1, CARD2, CARD3, CARD4, CARD5,
      CARD6, CARD7, CARD8, CARD9]
    likelihoods = cards.map { |c| CONVO1.chi_squared_likelihood(c) }
    likelihoods.each do |l|
      assert(l >= 0)
      assert(l <= 1)
    end
  end

  def test_chi_squared_likelihood_for_card_with_one_vote_returns_nil
    CONVO1.chi_squared_likelihood(CARD10)
  end

  # def test_card_entropy
  #   assert(CONVO1.card_entropy(CARD1) > 0)
  #   entropies = CONVO1.cards.map do |c|
  #     { c => CONVO1.card_entropy(c) }
  #   end
  # end
end

class VoteDataAdaptorTests < Minitest::Test
  def test_vote_data_adaptor
    assert(CONVO1.recommendation_for(SUE, CARD5).weighted_prediction < 0)
    assert(CONVO1.recommendation_for(SUE, CARD6).weighted_prediction > 0)
    assert(CONVO1.recommendation_for(SUE, CARD7).weighted_prediction < 0)
    assert_equal(CONVO1.recommendation_for(SUE, CARD8).weighted_prediction, 1)
  end
end