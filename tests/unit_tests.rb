require 'minitest/autorun'
require_relative './test_setup.rb'

require_relative '../app/similarity.rb'
require_relative '../app/card.rb'
require_relative '../app/vote.rb'
require_relative '../app/recommendation.rb'
require_relative '../app/user.rb'
require_relative '../app/conversation.rb'
require_relative '../scripts/vote_data_adapter.rb'

class CardTests < Minitest::Test
  def test_card_equality
    assert(Card.new('body').eql? Card.new('body'))
  end

  def test_card_hash_equality
    assert_equal(Card.new('body').hash, Card.new('body').hash)
  end
end

class UserTests < Minitest::Test
  def test_user_equality
    assert(User.new('bane').eql? User.new('bane'))
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
    assert(user1.cards_voted.include? card1)
  end

  def test_user_similarity_equality
    assert_equal(
      SUE.similarity_with(ROBERT),
      ROBERT.similarity_with(SUE)
      )
  end

  def test_user_similarity_excluding
    assert(ALICE.similarity_with(BOB) <
      ALICE.similarity_with(BOB, exclude=[CARD2])
      )
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
      Similarity::USER_DISTANCE.call(ALICE, BOB, exclude=[CARD2]))
    assert_equal(Similarity::USER_DISTANCE.call(ALICE, BOB, exclude=[CARD1,CARD2,CARD3,CARD4]), 0.0)
  end

  def test_pearson_score_range
    non_zero = false
    CONVO1.users.each do |user1|
      CONVO1.users.each do |user2|
        dist = Similarity::PEARSON_SCORE.call(user1, user2)
        assert(dist >= -1.0)
        assert(dist <= 1.0)
        non_zero = true if not dist.zero?
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
      Similarity::PEARSON_SCORE.call(SALLY, JAN, exclude=[CARD2,CARD4]))
    assert_equal(Similarity::PEARSON_SCORE.call(ALICE, BOB, exclude=[CARD1,CARD2,CARD3,CARD4]), 0.0)
  end
end

class VoteTests < Minitest::Test
  def test_vote_equality
    assert(Vote.new(CARD1,-1).eql? Vote.new(CARD1, -1))
  end

  def test_vote_hash_equality
    assert_equal(Vote.new(CARD1, -1).hash, Vote.new(CARD1, -1).hash)
  end

  def test_vote_converts_score_to_integer
    vote1 = Vote.new(CARD1, '-1')
    refute_equal(vote1.score.class, String)
  end
end

class RecommendationTests < Minitest::Test
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
end

class ConversationTests < Minitest::Test
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
end

class VoteDataAdaptorTests < Minitest::Test
  # def CSV.open(filename, opts, &block)
  #   @@mock_csv_file = []
  #   block.call(@@mock_csv_file)
  # end

  def test_load_users
    testRow = [['abc123','t9_barfig','1']]
    comparisonHash = { 'abc123' => User.new('abc123') }

    usersHash = VoteDataAdaptor::load_users(testRow)
    assert(usersHash.keys.eql? comparisonHash.keys)
    assert(usersHash.values.eql? comparisonHash.values)
  end

  def test_load_cards
    testRow = [['abc123','t9_barfig','1']]
    comparisonHash = { 't9_barfig' => Card.new('t9_barfig') }

    cardsHash = VoteDataAdaptor::load_cards(testRow)
    assert(cardsHash.keys.eql? comparisonHash.keys)
    assert(cardsHash.values.eql? comparisonHash.values)
  end

  def test_load_votes
    testRow = [['abc123','t9_barfig','1']]
    testUser = User.new('abc123')
    testCard = Card.new('t9_barfig')
    cards = { 't9_barfig' => testCard }
    users = { 'abc123' => testUser }

    votesHash = VoteDataAdaptor::load_votes(testRow, users, cards)
    assert(testUser.vote_for(testCard), Vote.new(testCard, '1'))
    assert(votesHash['t9_barfig']['abc123'].eql? Vote.new(testCard, '1'))
  end

  def test_load_convos
    testUser = User.new('abc123')
    testCard = Card.new('t9_barfig')
    cards = { 't9_barfig' => testCard }
    users = { 'abc123' => testUser }
    votes = { 't9_barfig' => { 'abc123' => testUser } }

    convoHash = VoteDataAdaptor::load_convos(users, cards, votes)
    assert_equal(convoHash['t9_barfig'].cards, [testCard])
    assert_equal(convoHash['t9_barfig'].users, [testUser])
  end

  def test_load_convos_only_includes_users_who_voted_on_card
    testUserAbc = User.new('abc123')
    testUserXyz = User.new('xyz456')
    testCard1 = Card.new('t9_barfig')
    testCard2 = Card.new('t9_bardtic')
    cardsHash = { 't9_barfig' => testCard1, 't9_bardtic' => testCard2 }
    usersHash = { 'abc123' => testUserAbc, 'xyz456' => testUserXyz }
    votesHash = {
      't9_barfig' => { 'abc123' => testUserAbc },
      't9_bardtic' => { 'xyz456' => testUserXyz }
    }

    convoHash = VoteDataAdaptor::load_convos(usersHash, cardsHash, votesHash)
    assert_equal(convoHash['t9_barfig'].users, [testUserAbc])
    assert_equal(convoHash['t9_barfig'].cards, [testCard1])
    assert_equal(convoHash['t9_bardtic'].users, [testUserXyz])
    assert_equal(convoHash['t9_bardtic'].cards, [testCard2])
  end

  # def test_vote_data_adaptor_initialize
  #   # assert(@@dataAdapt)
  #   assert(@@dataAdapt.cards)
  #   assert_instance_of(Card, @@dataAdapt.cards.values.first)
  #   assert(@@dataAdapt.users)
  #   assert_instance_of(User, @@dataAdapt.users.values.first)
  #   assert(@@dataAdapt.votes)
  #   assert_instance_of(Hash, @@dataAdapt.votes.values.first)
  #   assert(@@dataAdapt.convos)
  #   assert_instance_of(Conversation, @@dataAdapt.convos.values.first)
  # end

#   def test_vote_hash_properly_formed
#     a_card_body = @@dataAdapt.cards.values.first.body
#     a_username = @@dataAdapt.users.values.first.username
#     assert_instance_of(Hash, @@dataAdapt.votes[a_card_body])
#     assert_instance_of(Vote, @@dataAdapt.votes[a_card_body][a_username])
#   end

#   def test_calculate_convo_scores
#     @@dataAdapt.write_to_file(['eins','zwei','drei'], 'delete_please.csv')
#     assert_equal(@@mock_csv_file, ['eins','zwei','drei'])
#   end
end