POSTER = User.new('poster')

CARD1 = Card.new(POSTER, 'card1')
CARD2 = Card.new(POSTER, 'card2')
CARD3 = Card.new(POSTER, 'card3')
CARD4 = Card.new(POSTER, 'card4')
CARD5 = Card.new(POSTER, 'card5')
CARD6 = Card.new(POSTER, 'card6')
CARD7 = Card.new(POSTER, 'card7')
CARD8 = Card.new(POSTER, 'card8')
CARD9 = Card.new(POSTER, 'card9')
CARD10 = Card.new(POSTER, 'card10')
CARD_NO_ONE_HAS_VOTED_ON = Card.new(POSTER, 'no one has voted on this one')


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

POST1 = Post.new(
  [ROBERT, JAN, PHIL, SALLY, SUE],
  [CARD1, CARD2, CARD3, CARD4, CARD5,
    CARD6, CARD7, CARD8, CARD9, CARD10,
  CARD_NO_ONE_HAS_VOTED_ON]
  )
