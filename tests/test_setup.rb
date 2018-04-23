require_relative '../app/similarity.rb'
require_relative '../app/models/card.rb'
require_relative '../app/models/vote.rb'
require_relative '../app/models/user.rb'
require_relative '../app/models/conversation.rb'

def destroy_all
  User.delete_all
  Card.delete_all
  Vote.delete_all
end

def basic_setup
  @CARD1 = Card.create(body: 'card1')
  @CARD2 = Card.create(body: 'card2')
  @CARD3 = Card.create(body: 'card3')
  @CARD4 = Card.create(body: 'card4')
  @CARD5 = Card.create(body: 'card5')
  @CARD6 = Card.create(body: 'card6')
  @CARD7 = Card.create(body: 'card7')
  @CARD8 = Card.create(body: 'card8')
  @CARD9 = Card.create(body: 'card9')
  @CARD10 = Card.create(body: 'card10')
  @CARD_NO_ONE_HAS_VOTED_ON = Card.create(body: 'no one has voted on this one')

  @UPVOTE = 1
  @DOWNVOTE = -1

  @ROBERT = User.create(username: 'robert')
  Vote.create(card: @CARD1, user: @ROBERT, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @ROBERT, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @ROBERT, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @ROBERT, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD5, user: @ROBERT, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD6, user: @ROBERT, attitude: @UPVOTE, entropy: 1)

  @JAN = User.create(username: 'jan')
  Vote.create(card: @CARD1, user: @JAN, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @JAN, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @JAN, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @JAN, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD5, user: @JAN, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD6, user: @JAN, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD7, user: @JAN, attitude: @UPVOTE, entropy: 1)

  @PHIL = User.create(username: 'phil')
  Vote.create(card: @CARD1, user: @PHIL, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @PHIL, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @PHIL, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @PHIL, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD5, user: @PHIL, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD7, user: @PHIL, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD8, user: @PHIL, attitude: @UPVOTE, entropy: 1)

  @SALLY = User.create(username: 'sally')
  Vote.create(card: @CARD1, user: @SALLY, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @SALLY, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @SALLY, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @SALLY, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD5, user: @SALLY, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD8, user: @SALLY, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD9, user: @SALLY, attitude: @UPVOTE, entropy: 1)

  @SUE = User.create(username: 'sue')
  Vote.create(card: @CARD1, user: @SUE, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @SUE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @SUE, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @SUE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD5, user: @SUE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD9, user: @SUE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD10, user: @SUE, attitude: @UPVOTE, entropy: 1)

  @ALICE = User.create(username: 'alice')
  Vote.create(card: @CARD1, user: @ALICE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @ALICE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @ALICE, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @ALICE, attitude: @DOWNVOTE, entropy: 1)

  @BOB = User.create(username: 'bob')
  Vote.create(card: @CARD1, user: @BOB, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD2, user: @BOB, attitude: @UPVOTE, entropy: 1)
  Vote.create(card: @CARD3, user: @BOB, attitude: @DOWNVOTE, entropy: 1)
  Vote.create(card: @CARD4, user: @BOB, attitude: @DOWNVOTE, entropy: 1)

  @USER_WITH_NO_VOTES = User.create(username: 'user_with_no_votes')
end

TEST_CSV_ROWS = [
  %w[abc123 t9_barfig 1],
  %w[abc123 t9_barfpu 1],
  %w[abc123 t9_binsop 1],
  %w[blogmonster t9_barfig 1],
  %w[blogmonster t9_binsop 1],
  ['blogmonster', 't9_barfpu', '-1'],
  %w[blogmonster t9_baondig 1],
  %w[wrongwarp t9_biiviig 1]
].freeze
