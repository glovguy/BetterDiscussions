require 'minitest/autorun'
require_relative './recommendation.rb'
require_relative './posts.rb'
require_relative './test_data.rb'

class RecommendationTest < Minitest::Test

  def test_user_can_have_vote
    card1 = Card.new(Object.new, Object.new)
    vote1 = Vote.new(card1, Object.new)
    user1 = User.new('test', vote1)
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
    POST1.users.each do |u|
      dist = u.user_distance(ROBERT)
      assert(dist >= 0.0)
      assert(dist <= 1.0)
    end
  end

  def test_distance_with_self
    assert_equal(SUE.user_distance(SUE), 1.0)
  end

  def test_similar_users
    assert(!POST1.similar_users(SALLY).nil?)
  end

  def test_post_similar_users
    sally_top_matches = POST1.similar_users(SALLY)
    assert(sally_top_matches[ROBERT] > sally_top_matches[PHIL])
    assert(sally_top_matches[PHIL] > sally_top_matches[JAN])
  end

  def test_card_recommendations
    card_recs = POST1.card_recommendations(SUE)
    assert(!card_recs.nil?)
    assert(card_recs[CARD6] > 0)
    assert(card_recs[CARD7] < 0)
  end

  def test_card_recommendation_range
    POST1.card_recommendations(SUE).values.each do |v|
      assert(v >= -1)
      assert(v <= 1)
    end
  end

  def test_card_without_votes_returns_zero
    assert(POST1.card_recommendations(ROBERT)[CARD_NO_ONE_HAS_VOTED_ON] == 0)
  end

  def test_card_user_has_voted_on_is_given_recommendation
    assert(!POST1.card_recommendations(ROBERT)[CARD1].nil?)
  end
end
