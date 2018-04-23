# rubocop:disable Style/Documentation
require 'minitest/autorun'
require 'pry'
require_relative '../app/scripts/init_db.rb'
require_relative './test_setup.rb'

require_relative '../app/similarity.rb'
require_relative '../app/models/card.rb'
require_relative '../app/models/vote.rb'
require_relative '../app/models/recommendation.rb'
require_relative '../app/models/user.rb'
require_relative '../app/models/conversation.rb'
require_relative '../app/scripts/load_csv.rb'

class CardTests < Minitest::Test
  def test_card_equality
    assert_equal(Card.new(body: 'body'), Card.new(body: 'body'))
    assert(Card.new(body: 'body') != Card.new(body: 'something'))
  end

  def test_card_hash_equality
    assert_equal(Card.new(body: 'body').hash, Card.new(body: 'body').hash)
  end
end

class UserTests < Minitest::Test
  def test_user_equality
    assert_equal(User.new(username: 'bane'), User.new(username: 'bane'))
  end

  def test_user_hash_equality
    assert_equal(
      User.new(username: 'bane').hash,
      User.new(username: 'bane').hash
    )
  end

  def test_user_can_have_vote
    card1 = Card.create(body: Object.new)
    vote1 = Vote.create(card: card1, attitude: 0)
    user1 = User.create(username: 'test')
    assert_equal(false, user1.cards.include?(card1))
    vote1.user = user1
    vote1.save
    user1.reload
    assert(user1.cards.include?(card1))
    user1.delete
  end

  def test_user_similarity_equality
    assert_equal(
      SUE.similarity_with(ROBERT),
      ROBERT.similarity_with(SUE)
    )
  end

  def test_user_similarity_excluding
    assert(ALICE.similarity_with(BOB) <
      ALICE.similarity_with(BOB, exclude: [CARD2]))
  end
end

class SimiliarityMetricTests < Minitest::Test
  def test_user_distance_equality
    assert_equal(
      Similarity::USER_DISTANCE.call(SUE, ROBERT),
      Similarity::USER_DISTANCE.call(ROBERT, SUE)
    )
  end

  def test_user_distance_greater_than
    assert(
      Similarity::USER_DISTANCE.call(SUE, ROBERT) >
        Similarity::USER_DISTANCE.call(JAN, ROBERT)
    )
  end

  def test_distance_range
    User.all.each do |user1|
      User.all.each do |user2|
        dist = Similarity::USER_DISTANCE.call(user1, user2)
        assert(dist >= 0.0)
        assert(dist <= 1.0)
      end
    end
  end

  def test_distance_with_self
    assert_equal(Similarity::USER_DISTANCE.call(SUE, SUE), 1.0)
  end

  def test_distance_totally_unrelated_user
    assert_equal(Similarity::USER_DISTANCE.call(ALICE, USER_WITH_NO_VOTES), 0.0)
  end

  def test_user_distance_excluding
    assert(Similarity::USER_DISTANCE.call(ALICE, BOB) <
      Similarity::USER_DISTANCE.call(ALICE, BOB, [CARD2]))
    dist = Similarity::USER_DISTANCE.call(
      ALICE,
      BOB,
      [CARD1, CARD2, CARD3, CARD4]
    )
    assert_equal(dist, 0.0)
  end

  def test_pearson_score_range
    non_zero = false
    User.all.each do |user1|
      User.all.each do |user2|
        dist = Similarity::PEARSON_SCORE.call(user1, user2)
        assert(dist >= -1.0)
        assert(dist <= 1.0)
        non_zero = true unless dist.zero?
      end
    end
    assert(non_zero)
  end

  def test_pearson_score_commutitivity
    assert_equal(Similarity::USER_DISTANCE.call(PHIL, SUE),
                 Similarity::USER_DISTANCE.call(PHIL, SUE))
  end

  def test_pearson_score_excluding
    assert(Similarity::PEARSON_SCORE.call(SALLY, JAN) <
      Similarity::PEARSON_SCORE.call(SALLY, JAN, [CARD2, CARD4]))
    assert_equal(
      Similarity::PEARSON_SCORE.call(ALICE, BOB, [CARD1, CARD2, CARD3, CARD4]),
      0.0
    )
  end
end

class VoteTests < Minitest::Test
  def test_vote_equality
    assert_equal(
      Vote.new(card: CARD1, attitude: 0),
      Vote.new(card: CARD1, attitude: 0)
    )
  end

  def test_vote_hash_equality
    assert_equal(
      Vote.new(card: CARD1, attitude: 0).hash,
      Vote.new(card: CARD1, attitude: 0).hash
    )
  end

  def test_cast_vote
    test_card = Card.create(body: 'test body')
    test_user = User.create(username: 'test45')
    test_vote = Vote.new(card: test_card, user: test_user, attitude: 1)
    assert_nil(test_vote.entropy)
    test_vote.save
    assert_equal(1, test_vote.entropy)
    test_user.delete
    test_vote.delete
    test_card.delete
  end
end

class RecommendationTests < Minitest::Test
  def test_recommendation_adding
    rec1 = Recommendation.new(1, 1)
    rec2 = Recommendation.new(0, 1)
    combined_rec = rec1 + rec2
    assert_equal(0.5, combined_rec.weighted_prediction)
  end

  def test_adding_differently_weighted_recommendations
    rec1 = Recommendation.new(0.6, 4)
    rec2 = Recommendation.new(0.3, 2)
    combined_rec = rec1 + rec2
    assert_equal(0.5, combined_rec.weighted_prediction)
  end

  def test_recommendations
    rec1 = Recommendation.new(1.0, 1.0)
    rec2 = Recommendation.new(0.5, 6.0)
    assert_equal(1.0, rec1.weighted_prediction)
    assert_equal(0.5, rec2.weighted_prediction)
  end

  def test_recommendations_range
    recs = Card.all.map { |c| Conversation::recommendation_for(PHIL, c) }
    recs.reject(&:nil?).each do |rec|
      assert(rec.weighted_prediction >= 0)
      assert(rec.weighted_prediction <= 1)
    end
  end

  def test_recommendation_for_totally_unrelated_user
    assert_nil(ALICE.recommendation_for(USER_WITH_NO_VOTES, CARD1))
  end

  def test_recommendation_likelihood_of_pos_attitude
    rec1 = Recommendation.new(0, 2)
    rec2 = Recommendation.new(0.5, 6)
    pos_att = 1
    assert_equal(0.0, rec1.likelihood_of(pos_att))
    assert_equal(0.5, rec2.likelihood_of(pos_att))
  end

  def test_recommendation_likelihood_of_neg_attitude
    rec1 = Recommendation.new(0, 2)
    rec2 = Recommendation.new(0.5, 6)
    neg_att = 0
    assert_equal(rec1.likelihood_of(neg_att), 1.0)
    assert_equal(rec2.likelihood_of(neg_att), 0.5)
  end
end

class ConversationTests < Minitest::Test
  def test_recommendation_for
    assert(Conversation::recommendation_for(SUE, CARD5).weighted_prediction < 0.5)
    assert(Conversation::recommendation_for(SUE, CARD6).weighted_prediction > 0.5)
    assert(Conversation::recommendation_for(SUE, CARD7).weighted_prediction < 0.5)
    assert_equal(Conversation::recommendation_for(SUE, CARD8).weighted_prediction, 1)
  end

  def test_card_recommendation_range
    CARD1.users.each do |u|
      assert(Conversation::recommendation_for(u, CARD1).weighted_prediction >= 0)
      assert(Conversation::recommendation_for(u, CARD1).weighted_prediction <= 1)
    end
  end

  def test_card_without_votes_returns_nil
    assert_nil(Conversation::recommendation_for(ROBERT, CARD_NO_ONE_HAS_VOTED_ON))
  end

  def test_card_user_has_voted_on_is_given_recommendation
    assert_equal(
      0.4913338099395003,
      Conversation::recommendation_for(ROBERT, CARD1).weighted_prediction
    )
  end

  def test_user_with_no_votes_is_given_nil_recommendation
    assert_nil(Conversation::recommendation_for(USER_WITH_NO_VOTES, CARD1))
  end

  def test_entropy_lambda
    assert_equal(ENTROPY.call(0.9), 0.13680278410054497)
  end

  def test_entropy_range
    (1..10).to_a.each do |i|
      assert(ENTROPY.call(0.1 * i) <= 1.0)
      assert(ENTROPY.call(0.1 * i) >= 0.0)
    end
  end

  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  def test_conversation_vote_entropy
    assert_equal(
      0.5174903359987708,
      Conversation::vote_entropy(ROBERT, Vote.new(card: CARD7, attitude: 1))
    )
    assert_equal(
      0.5,
      Conversation::vote_entropy(JAN, Vote.new(card: CARD9, attitude: 1))
    )
    assert_equal(
      0.5188759492631944,
      Conversation::vote_entropy(PHIL, Vote.new(card: CARD9, attitude: 1))
    )
    assert_equal(
      0.5122656108674634,
      Conversation::vote_entropy(SALLY, Vote.new(card: CARD7, attitude: 1))
    )
    assert_equal(
      0.48498113460066844,
      Conversation::vote_entropy(SALLY, Vote.new(card: CARD7, attitude: 0))
    )
    assert_equal(
      0.5090950592365232,
      Conversation::vote_entropy(SUE, Vote.new(card: CARD7, attitude: 1))
    )
  end
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  def test_vote_entropy_is_one_for_user_and_vote_without_recommendation
    vote_on_card1 = Vote.new(card: CARD1, attitude: 1)
    assert_equal(
      Conversation::vote_entropy(USER_WITH_NO_VOTES, vote_on_card1),
      1
    )
  end
end

class LoadCsvTests < Minitest::Test
  def test_load_users
    User.delete_all # Leaky tests!
    Card.delete_all # Add setup instead?
    Vote.delete_all
    test_row = [%w[abc123 t9_barfig 1]]
    assert_nil(User.where(username: 'abc123').take)
    LoadCsv.users(test_row)
    test_user = User.where(username: 'abc123').take
    assert_equal(test_user, User.new(username: 'abc123'))
    test_user.delete
  end

  def test_load_cards
    test_row = [%w[abc123 t9_barfig 1]]
    assert_nil(Card.where(body: 't9_barfig').take)
    LoadCsv.cards(test_row)
    assert_equal(Card.where(body: 't9_barfig').take, Card.new(body: 't9_barfig'))
  end

  def test_load_votes
    test_row = [%w[abc123 t9_barfig 1]]
    test_user = User.where(username: 'abc123').take
    test_card = Card.where(body: 't9_barfig').take
    assert_nil(Vote.where(user: test_user, card: test_card).take)
    LoadCsv.votes(test_row)
    new_vote = Vote.where(user: test_user, card: test_card).take
    assert_equal(new_vote.attitude, 1)
  end

  def test_write_file
    def CSV.open(_filename, _opts, &block)
      block.call(@@mock_csv_file)
    end
    @@mock_csv_file = []
    LoadCsv.write_to_file(%w[eins zwei drei], 'delete_please.csv')
    assert_equal(@@mock_csv_file, %w[eins zwei drei])
  end
end

# rubocop:enable Style/Documentation
