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
    usernames = rows.map(&:first)
    progress = ProgressBar.new(usernames.length) if verbose
    usernames.uniq.map do |un|
      User.create(username: un)
      progress.increment! if verbose
    end
    puts "Users loaded. There are #{User.count} users." if verbose
  end

  def self.cards(rows, verbose = false)
    puts 'Initializing cards...' if verbose
    post_ids = rows.map(&:second).uniq
    progress = ProgressBar.new(post_ids.length) if verbose
    post_ids.each do |body|
      Card.create(body: body)
      progress.increment! if verbose
    end
    puts "Cards loaded. There are #{Card.count} cards." if verbose
  end

  def self.votes(rows, verbose = false)
    puts 'Initializing votes...' if verbose
    progress = ProgressBar.new(rows.length) if verbose
    rows.each do |row|
      vote_from_row(row)
      progress.increment! if verbose
    end
    puts "Votes loaded. There are #{votes.length} votes." if verbose
  end

  def self.vote_from_row(row)
    username, post_id, vote_value = row
    user = User.where(username: username).take
    card = Card.where(body: post_id).take
    Vote.create(user: user, card: card, attitude: vote_value)
  end
end
