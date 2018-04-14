require 'csv'
require 'progress_bar'
require_relative '../models/user.rb'
require_relative '../models/vote.rb'
require_relative '../models/card.rb'
require_relative '../models/conversation.rb'

# methods for loading data from csv
module LoadCsv
  def self.write_to_file(data, filename)
    CSV.open(filename, 'w') do |csv|
      data.each { |s| csv << s }
    end
  end

  def self.csv_rows(filepath, verbose = false)
    puts 'Loading file into memory...' if verbose
    progress = ProgressBar.new(IO.readlines(filepath).size) if verbose
    rows = []
    CSV.foreach(filepath) do |row|
      rows << row
      progress.increment! if verbose
    end
    puts 'File in memory.' if verbose
    rows
  end

  def self.users(rows, verbose = false)
    puts 'Initializing users...' if verbose
    users = {}
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      username, _post_id, _vote_value = row
      users[username] = User.new(username)
      progress.increment! if verbose
    end
    puts "Users loaded. There are #{users.length} users." if verbose
    users
  end

  def self.users_who_voted_on_cards(rows, cards, verbose = false)
    puts 'Initializing users who voted on those cards...' if verbose
    users = {}
    users.default_proc = proc do |hash, key|
      hash[key] = User.new(key)
    end
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      username, post_id, vote_value = row
      card = cards.select { |c| c.body == post_id }.first
      next unless card
      vote = Vote.new(card, vote_value)
      users[username].add_vote(vote)
      progress.increment! if verbose
    end
    puts "Users loaded. There are #{users.length} users." if verbose
    users.values
  end

  def self.cards(rows, verbose = false)
    puts 'Initializing cards...' if verbose
    cards = {}
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      _username, post_id, _vote_value = row
      card = Card.new(post_id)
      cards[post_id] = card
      progress.increment! if verbose
    end
    puts "Cards loaded. There are #{cards.length} cards." if verbose
    cards
  end

  def self.cards_with_more_than_one_vote(rows, verbose = false)
    puts 'Initializing cards with more than one vote...' if verbose
    cards_seen = {}.tap { |h| h.default = 0 }
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      _username, post_id, _vote_value = row
      cards_seen[post_id] += 1
      progress.increment! if verbose
    end
    cards_seen.select! { |_post_id, count| count > 1 }
    puts "Cards loaded. There are #{cards.length} cards." if verbose
    cards_seen.keys.map { |post_id| Card.new(post_id) }
  end

  def self.votes(rows, users, cards, verbose = false)
    puts 'Initializing votes...' if verbose
    progress = ProgressBar.new(rows.length) if verbose
    votes = {}
    rows.each do |row|
      username, post_id, vote_value = row
      user = users[username]
      card = cards[post_id]
      vote = Vote.new(card, vote_value)
      user.add_vote(vote)
      votes[post_id] ||= {}
      votes[post_id][username] = vote
      progress.increment! if verbose
    end
    puts "Votes loaded. There are #{votes.length} votes." if verbose
    votes
  end

  def self.convos(users, cards, votes, verbose = false)
    puts 'Initializing convos...' if verbose
    progress = ProgressBar.new(cards.length) if verbose
    convos = {}
    cards.each_value do |card|
      usernames_on_card = votes[card.body].keys
      users_on_card = users.values.select do |user|
        usernames_on_card.include?(user.username)
      end
      convos[card.body] = Conversation.new(users_on_card, card)
      progress.increment! if verbose
    end
    puts "Convos loaded. There are #{convos.length} convos." if verbose
    convos
  end
end
