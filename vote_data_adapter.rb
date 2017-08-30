require 'csv'
require_relative './cards.rb'
require_relative './conversations.rb'
require 'progress_bar'


class VoteDataAdaptor
  attr_reader :cards
  attr_reader :users
  attr_reader :votes
  attr_reader :convos

  def initialize(filepath, verbose=true)
    @filesize = IO.readlines(filepath).size
    @verbose = verbose
    load_csv_rows(filepath)
    load_users
    load_cards
    load_votes
    load_convos
  end

  def confirm_no_duplicate_cards
    cards_with_more_than_one_vote = @cards.map do |card|
      @votes.select {|vote| vote.card==card }.empty? ? nil : card
    end
    cards_with_more_than_one_vote = cards_with_more_than_one_vote.reject { |c| c.nil? }
    puts " Number of cards with more than one vote: #{cards_with_more_than_one_vote.length}"
    puts ' No cards with more than one vote' unless not cards_with_more_than_one_vote.empty?
  end

  def calculate_convo_scores(batch_size=5000)
    max_batch = Math.min(batch_size, convos.length)
    bar4 = ProgressBar.new(max_batch) if @verbose
    entropies = {}
    chi2scores = {}
    @convos.first(batch_size).each do |con|
      card = convo.cards.first
      ent = convo.card_entropy(card)
      chi = convo.chi_squared_likelihood(card)
      entropies[card.body] = ent unless ent.nil?
      chi2scores[card.body] = chi unless chi.nil?
      bar4.increment! if @verbose
    end

    non_nil_entropies = entropies.sort_by { |e| e[1] }
    non_nil_chi2scores = chi2scores.sort_by { |s| s[1] }

    puts '  Entropies:' if @verbose
    puts 'lowest (good):' if @verbose
    non_nil_entropies.take(5).each {|e| puts e}
    puts 'highest (bad):' if @verbose
    non_nil_entropies.reverse.take(5).each {|e| puts e}
    puts '  Chi2 Scores:' unless non_nil_chi2scores.empty? if @verbose
    puts 'lowest (good):' unless non_nil_chi2scores.empty? if @verbose
    non_nil_chi2scores.take(5).each {|s| puts s}
    puts 'highest (bad):' unless non_nil_chi2scores.empty? if @verbose
    non_nil_chi2scores.reverse.take(5).each {|s| puts s}
    puts " Number of non-nil entropies: #{non_nil_entropies.length}" if @verbose
    puts " Number of non-nil chi2 scores: #{non_nil_chi2scores.length}" if @verbose
    puts ' All entropies were nil' unless not non_nil_entropies.empty? if @verbose
    puts ' All chi2 scores were nil' unless not non_nil_chi2scores.empty? if @verbose

    write_to_file(non_nil_chi2scores, 'chi2Scores.csv')
    write_to_file(non_nil_entropies, 'entropies.csv')
  end

  def write_to_file(data, filename)
    CSV.open(filename, "w") do |csv|
      data.each { |s| csv << s }
    end
  end

  private

    def load_csv_rows(filepath)
      puts 'Loading file into memory...' if @verbose
      bar0 = ProgressBar.new(@filesize) if @verbose
      @rows = []
      CSV.foreach(filepath) do |row|
        @rows << row
        bar0.increment! if @verbose
      end
      @row_count = @rows.length
      puts 'File in memory.' if @verbose
    end

    def load_users
      users = []
      bar1 = ProgressBar.new(@row_count) if @verbose
      @rows.each do |row|
        username, post_id, vote_value = row
        users << User.new(username)
        bar1.increment! if @verbose
      end
      puts 'Users loaded. Removing duplicates...' if @verbose
      @users = users.uniq
      puts "There are #{@users.length} users." if @verbose
    end

    def load_cards
      cards = []
      bar2 = ProgressBar.new(@row_count) if @verbose
      @rows.each do |row|
        username, post_id, vote_value = row
        cards << Card.new(post_id)
        bar2.increment! if @verbose
      end
      puts 'Cards loaded. Removing duplicates...' if @verbose
      @cards = cards.uniq
      puts "There are #{@cards.length} cards." if @verbose
    end

    def load_votes
      bar3 = ProgressBar.new(@row_count) if @verbose
      @votes = []
      @rows.each do |row|
        username, post_id, vote_value = row
        user = @users.select { |u| u.username == username }.first
        card = @cards.select { |c| c.body == post_id }.first
        vote = Vote.new(card, vote_value)
        user.add_vote(vote)
        @votes << vote
        bar3.increment! if @verbose
      end
      puts "Votes loaded. There are #{@votes.length} votes." if @verbose
    end

    def load_convos
      @convos = []
      @cards.each do |card|
        users_on_card = @users.select do |user|
          not user.vote_on(card).nil?
        end
        @convos << Conversation.new(users_on_card, card)
      end
    end
end
