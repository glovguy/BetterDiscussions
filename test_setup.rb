CARD1 = Card.new('card1')
CARD2 = Card.new('card2')
CARD3 = Card.new('card3')
CARD4 = Card.new('card4')
CARD5 = Card.new('card5')
CARD6 = Card.new('card6')
CARD7 = Card.new('card7')
CARD8 = Card.new('card8')
CARD9 = Card.new('card9')
CARD10 = Card.new('card10')
CARD_NO_ONE_HAS_VOTED_ON = Card.new('no one has voted on this one')

ROBERT = User.new('robert',
    Vote.new(CARD1, -1),
    Vote.new(CARD2, -1),
    Vote.new(CARD3, 1),
    Vote.new(CARD4, -1),
    Vote.new(CARD5, -1),
    Vote.new(CARD6, 1)
  )

JAN = User.new('jan',
    Vote.new(CARD1, -1),
    Vote.new(CARD2, 1),
    Vote.new(CARD3, 1),
    Vote.new(CARD4, 1),
    Vote.new(CARD5, -1),
    Vote.new(CARD6, 1),
    Vote.new(CARD7, 1)
  )

PHIL = User.new('phil',
    Vote.new(CARD1, 1),
    Vote.new(CARD2, -1),
    Vote.new(CARD3, 1),
    Vote.new(CARD4, -1),
    Vote.new(CARD5, -1),
    Vote.new(CARD7, -1),
    Vote.new(CARD8, 1)
  )

SALLY = User.new('sally',
    Vote.new(CARD1, -1),
    Vote.new(CARD2, -1),
    Vote.new(CARD3, 1),
    Vote.new(CARD4, -1),
    Vote.new(CARD5, 1),
    Vote.new(CARD8, 1),
    Vote.new(CARD9, 1)
  )

SUE = User.new('sue',
  Vote.new(CARD1, 1),
  Vote.new(CARD2, -1),
  Vote.new(CARD3, 1),
  Vote.new(CARD4, -1),
  Vote.new(CARD5, -1),
  Vote.new(CARD9, -1),
  Vote.new(CARD10, 1)
  )

ALICE = User.new('alice',
  Vote.new(CARD1, -1),
  Vote.new(CARD2, -1),
  Vote.new(CARD3, -1),
  Vote.new(CARD4, -1),
  )

BOB = User.new('bob',
  Vote.new(CARD1, 1),
  Vote.new(CARD2, 1),
  Vote.new(CARD3, -1),
  Vote.new(CARD4, -1)
  )

USER_WITH_NO_VOTES = User.new('user_with_no_votes')

CONVO1 = Conversation.new(
  [ROBERT, JAN, PHIL, SALLY, SUE],
  [CARD1, CARD2, CARD3, CARD4, CARD5,
    CARD6, CARD7, CARD8, CARD9, CARD10,
    CARD_NO_ONE_HAS_VOTED_ON]
  )
