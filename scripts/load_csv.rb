require 'csv'
require 'progress_bar'
require_relative '../app/user.rb'
require_relative '../app/vote.rb'
require_relative '../app/card.rb'
require_relative '../app/conversation.rb'

module LoadCsv
  # def self.data(filepath, verbose=false)
  #   rows = csv_rows(filepath, verbose)
  #   users = users(rows, verbose)
  #   cards = cards(rows, verbose)
  #   votes = votes(rows, verbose)
  #   convos = convos(rows, verbose)
  # end

  def self.write_to_file(data, filename)
    CSV.open(filename, "w") do |csv|
      data.each { |s| csv << s }
    end
  end

  def self.csv_rows(filepath, verbose=false)
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

  def self.users(rows, verbose=false)
    puts 'Initializing users...' if verbose
    users = Hash.new
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      username, post_id, vote_value = row
      users[username] = User.new(username)
      progress.increment! if verbose
    end
    puts "Users loaded. There are #{users.length} users." if verbose
    users
  end

  def self.cards(rows, verbose=false)
    puts 'Initializing cards...' if verbose
    cards = Hash.new
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      username, post_id, vote_value = row
      card = Card.new(post_id)
      cards[post_id] = card
      progress.increment! if verbose
    end
    puts "Cards loaded. There are #{cards.length} cards." if verbose
    cards
  end

  def self.cards_with_more_than_one_vote(rows, verbose=false)
    puts 'Initializing cards with more than one vote...' if verbose
    cards_seen = Hash.new.tap { |h| h.default = 0 }
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      username, post_id, vote_value = row
      cards_seen[post_id] += 1
      progress.increment! if verbose
    end
    cards_seen.select! { |post_id, count| count > 1 }
    puts "Cards loaded. There are #{cards.length} cards." if verbose
    cards_seen.keys.map { |post_id| Card.new(post_id) }
  end

  def self.votes(rows, users, cards, verbose=false)
    puts 'Initializing votes...' if verbose
    progress = ProgressBar.new(rows.length) if verbose
    votes = Hash.new
    rows.each do |row|
      username, post_id, vote_value = row
      user = users[username] #@users.select { |u| u.username == username }.first
      card = cards[post_id] #@cards.select { |c| c.body == post_id }.first
      vote = Vote.new(card, vote_value)
      user.add_vote(vote)
      votes[post_id] ||= Hash.new
      votes[post_id][username] = vote
      progress.increment! if verbose
    end
    puts "Votes loaded. There are #{votes.length} votes." if verbose
    votes
  end

  def self.convos(users, cards, votes, verbose=false)
    puts 'Initializing convos...' if verbose
    progress = ProgressBar.new(cards.length) if verbose
    convos = Hash.new
    cards.values.each do |card|
      # users_on_card = @users.values.select do |user|
      #   not user.vote_on(card).nil?
      # end
      ## Utilize the hashes to speed this up!
      usernames_on_card = votes[card.body].keys
      users_on_card = users.values.select { |user| usernames_on_card.include?(user.username) }
      convos[card.body] = Conversation.new(users_on_card, card)
      progress.increment! if verbose
    end
    puts "Convos loaded. There are #{convos.length} convos." if verbose
    convos
  end

  # def self.convo_from_csv()
  # end
end
