# rubocop:disable Style/Documentation

require 'minitest/autorun'
require_relative './test_setup.rb'

require_relative '../app/similarity.rb'
require_relative '../app/card.rb'
require_relative '../app/vote.rb'
require_relative '../app/recommendation.rb'
require_relative '../app/user.rb'
require_relative '../app/conversation.rb'
require_relative '../scripts/load_csv.rb'

class CardTests < Minitest::Test
  def test_card_equality
    assert_equal(Card.new('body'), Card.new('body'))
    assert(Card.new('body') != Card.new('something'))
  end

  def test_card_hash_equality
    assert_equal(Card.new('body').hash, Card.new('body').hash)
  end
end

class UserTests < Minitest::Test
  def test_user_equality
    assert_equal(User.new('bane'), User.new('bane'))
  end

  def test_user_hash_equality
    assert_equal(User.new('bane').hash, User.new('bane').hash)
  end

  def test_user_can_have_vote
    card1 = Card.new(Object.new)
    vote1 = Vote.new(card1, 0)
    user1 = User.new('test')
    assert_equal(false, user1.cards_voted.include?(card1))
    user1.add_vote(vote1)
    assert(user1.cards_voted.include?(card1))
  end

  def test_user_similarity_equality
    assert_equal(
      SUE.similarity_with(ROBERT),
      ROBERT.similarity_with(SUE)
    )
  end

  def test_user_similarity_excluding
    assert(ALICE.similarity_with(BOB) <
      ALICE.similarity_with(BOB, [CARD2]))
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
    CONVO1.users.each do |user1|
      CONVO1.users.each do |user2|
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
    CONVO1.users.each do |user1|
      CONVO1.users.each do |user2|
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
    assert_equal(Vote.new(CARD1, -1), Vote.new(CARD1, -1))
  end

  def test_vote_hash_equality
    assert_equal(Vote.new(CARD1, -1).hash, Vote.new(CARD1, -1).hash)
  end
end

class RecommendationTests < Minitest::Test
  def test_recommendation_adding
    rec1 = Recommendation.new(Attitude.new(0.6), 2)
    rec2 = Recommendation.new(Attitude.new(0.4), 4)
    combined_rec = rec1 + rec2
    assert_equal(
      combined_rec.weighted_prediction,
      0.5
    )
  end

  def test_recommendations
    rec1 = Recommendation.new(Attitude.new(1.0), 1.0)
    rec2 = Recommendation.new(Attitude.new(0.5), 6.0)
    assert_equal(rec1.weighted_prediction, 1.0)
    assert_equal(rec2.weighted_prediction, 0.5)
  end

  def test_recommendations_range
    recs = CONVO1.cards.map { |c| CONVO1.recommendation_for(PHIL, c) }
    recs.reject(&:nil?).each do |rec|
      assert(rec.weighted_prediction >= 0)
      assert(rec.weighted_prediction <= 1)
    end
  end

  def test_recommendation_for_totally_unrelated_user
    assert_nil(ALICE.recommendation_for(USER_WITH_NO_VOTES, CARD1))
  end

  def test_recommendation_likelihood_of_pos_attitude
    rec1 = Recommendation.new(Attitude.new(-1), 2)
    rec3 = Recommendation.new(Attitude.new(0.25), 6)
    pos_att = Attitude.new(1)
    assert_equal(rec1.likelihood_of(pos_att), 0.0)
    assert_equal(rec3.likelihood_of(pos_att), 0.5)
  end

  def test_recommendation_likelihood_of_neg_attitude
    rec1 = Recommendation.new(Attitude.new(-1), 2)
    rec2 = Recommendation.new(Attitude.new(0.75), 6)
    neg_att = Attitude.new(-1)
    assert_equal(rec1.likelihood_of(neg_att), 1.0)
    assert_equal(rec2.likelihood_of(neg_att), 0.5)
    assert_equal(rec2.likelihood_of(neg_att), 0.5)
  end
end

class ConversationTests < Minitest::Test
  def test_recommendation_for
    assert(CONVO1.recommendation_for(SUE, CARD5).weighted_prediction < 0.5)
    assert(CONVO1.recommendation_for(SUE, CARD6).weighted_prediction > 0.5)
    assert(CONVO1.recommendation_for(SUE, CARD7).weighted_prediction < 0.5)
    assert_equal(CONVO1.recommendation_for(SUE, CARD8).weighted_prediction, 1)
  end

  def test_card_recommendation_range
    CONVO1.users.each do |u|
      assert(CONVO1.recommendation_for(u, CARD1).weighted_prediction >= -1)
      assert(CONVO1.recommendation_for(u, CARD1).weighted_prediction <= 1)
    end
  end

  def test_card_without_votes_returns_nil
    assert_nil(CONVO1.recommendation_for(ROBERT, CARD_NO_ONE_HAS_VOTED_ON))
  end

  def test_card_user_has_voted_on_is_given_recommendation
    assert_equal(
      CONVO1.recommendation_for(ROBERT, CARD1).weighted_prediction,
      0.5224077499274828
    )
  end

  def test_user_with_no_votes_is_given_nil_recommendation
    assert_nil(CONVO1.recommendation_for(USER_WITH_NO_VOTES, CARD1))
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
  def test_vote_entropy
    assert_equal(
      CONVO1.vote_entropy(ROBERT, Vote.new(CARD7, 1)),
      0.5174903359987708
    )
    assert_equal(
      CONVO1.vote_entropy(JAN, Vote.new(CARD9, 1)),
      0.5
    )
    assert_equal(
      CONVO1.vote_entropy(PHIL, Vote.new(CARD9, 1)),
      0.5188759492631944
    )
    assert_equal(
      CONVO1.vote_entropy(SALLY, Vote.new(CARD7, 1)),
      0.5122656108674634
    )
    assert_equal(
      CONVO1.vote_entropy(SALLY, Vote.new(CARD7, -1)),
      0.48498113460066844
    )
    assert_equal(
      CONVO1.vote_entropy(SUE, Vote.new(CARD7, 1)),
      0.5090950592365232
    )
  end
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  def test_vote_entropy_is_one_for_user_and_vote_without_recommendation
    assert_equal(CONVO1.vote_entropy(USER_WITH_NO_VOTES, Vote.new(CARD1, 1)), 1)
  end
end

class LoadCsvTests < Minitest::Test
  def test_load_users
    test_row = [%w[abc123 t9_barfig 1]]
    comparison_hash = { 'abc123' => User.new('abc123') }

    users_hash = LoadCsv.users(test_row)
    assert_equal(users_hash.keys, comparison_hash.keys)
    assert_equal(users_hash.values, comparison_hash.values)
  end

  def test_users_who_voted_on_cards
    cards = [Card.new('t9_barfig')]
    users = LoadCsv.users_who_voted_on_cards(TEST_CSV_ROWS, cards)
    comparison = [User.new('abc123'), User.new('blogmonster')]
    assert_equal(users, comparison)
  end

  def test_load_cards
    test_row = [%w[abc123 t9_barfig 1]]
    comparison_hash = { 't9_barfig' => Card.new('t9_barfig') }

    cards_hash = LoadCsv.cards(test_row)
    assert(cards_hash.keys.eql?(comparison_hash.keys))
    assert_equal(cards_hash.values, comparison_hash.values)
  end

  def test_load_cards_with_more_than_one_vote
    cards = LoadCsv.cards_with_more_than_one_vote(TEST_CSV_ROWS)
    expected = [
      Card.new('t9_barfig'),
      Card.new('t9_barfpu'),
      Card.new('t9_binsop')
    ]
    assert_equal(expected, cards)
  end

  def test_load_votes
    test_row = [%w[abc123 t9_barfig 1]]
    test_user = User.new('abc123')
    test_card = Card.new('t9_barfig')
    cards = { 't9_barfig' => test_card }
    users = { 'abc123' => test_user }

    votes_hash = LoadCsv.votes(test_row, users, cards)
    assert(test_user.vote_for(test_card), Vote.new(test_card, '1'))
    assert_equal(votes_hash['t9_barfig']['abc123'], Vote.new(test_card, '1'))
  end

  def test_load_convos
    test_user = User.new('abc123')
    test_card = Card.new('t9_barfig')
    cards = { 't9_barfig' => test_card }
    users = { 'abc123' => test_user }
    votes = { 't9_barfig' => { 'abc123' => test_user } }

    convo_hash = LoadCsv.convos(users, cards, votes)
    assert_equal(convo_hash['t9_barfig'].cards, [test_card])
    assert_equal(convo_hash['t9_barfig'].users, [test_user])
  end

  # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
  def test_load_convos_only_includes_users_who_voted_on_card
    test_user_abc = User.new('abc123')
    test_user_xyz = User.new('xyz456')
    test_card1 = Card.new('t9_barfig')
    test_card2 = Card.new('t9_bardtic')
    cards_hash = { 't9_barfig' => test_card1, 't9_bardtic' => test_card2 }
    users_hash = { 'abc123' => test_user_abc, 'xyz456' => test_user_xyz }
    votes_hash = {
      't9_barfig' => { 'abc123' => test_user_abc },
      't9_bardtic' => { 'xyz456' => test_user_xyz }
    }

    convo_hash = LoadCsv.convos(users_hash, cards_hash, votes_hash)
    assert_equal(convo_hash['t9_barfig'].users, [test_user_abc])
    assert_equal(convo_hash['t9_barfig'].cards, [test_card1])
    assert_equal(convo_hash['t9_bardtic'].users, [test_user_xyz])
    assert_equal(convo_hash['t9_bardtic'].cards, [test_card2])
  end
  # rubocop:enable Metrics/MethodLength,Metrics/AbcSize

  # rubocop:disable Lint/NestedMethodDefinition,Style/ClassVars
  def test_write_file
    def CSV.open(_filename, _opts, &block)
      block.call(@@mock_csv_file)
    end
    @@mock_csv_file = []
    LoadCsv.write_to_file(%w[eins zwei drei], 'delete_please.csv')
    assert_equal(@@mock_csv_file, %w[eins zwei drei])
  end
  # rubocop:enable Lint/NestedMethodDefinition,Style/ClassVars
end

# rubocop:enable Style/Documentation
