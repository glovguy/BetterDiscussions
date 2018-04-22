require 'progress_bar'
require_relative '../app/user.rb'
require_relative '../app/vote.rb'
require_relative '../app/card.rb'
require_relative '../app/conversation.rb'

# Functions for calculating and comparing entropies of many convos
module Analysis
  def self.calculate_convo_scores(convos, batch_size = 5000)
    max_batch = [batch_size, convos.length].min
    progress = ProgressBar.new(max_batch) if verbose
    entropies = {}
    chi2scores = {}
    convos.values.first(batch_size).each do |convo|
      card = convo.cards.first
      ent = convo.card_entropy(card)
      chi = convo.chi_squared_likelihood(card)
      entropies[card.body] = ent unless ent.nil?
      chi2scores[card.body] = chi unless chi.nil?
      progress.increment! if verbose
    end

    non_nil_entropies = entropies.sort_by { |e| e[1] }
    non_nil_chi2scores = chi2scores.sort_by { |s| s[1] }

    puts '  Entropies:' if verbose
    puts 'lowest (good):' if verbose
    non_nil_entropies.take(5).each { |e| puts e }
    puts 'highest (bad):' if verbose
    non_nil_entropies.reverse.take(5).each { |e| puts e }
    puts '  Chi2 Scores:' if verbose && !non_nil_chi2scores.empty?
    puts 'lowest (good):' if verbose && !non_nil_chi2scores.empty?
    non_nil_chi2scores.take(5).each { |s| puts s }
    puts 'highest (bad):' if verbose && !non_nil_chi2scores.empty?
    non_nil_chi2scores.reverse.take(5).each { |s| puts s }
    if verbose
      puts " Number of non-nil entropies: #{non_nil_entropies.length}"
      puts " Number of non-nil chi2 scores: #{non_nil_chi2scores.length}"
      puts ' All entropies were nil' if non_nil_entropies.empty?
      puts ' All chi2 scores were nil' if non_nil_chi2scores.empty?
    end

    write_to_file(non_nil_chi2scores, 'chi2Scores.csv')
    write_to_file(non_nil_entropies, 'entropies.csv')
  end

  # def self.confirm_no_duplicate_cards
  #   cards_with_more_than_one_vote = @cards.map do |card|
  #     @votes.select {|vote| vote.card==card }.empty? ? nil : card
  #   end
  #   cards_with_more_than_one_vote = cards_with_more_than_one_vote.reject { |c| c.nil? }
  #   puts " Number of cards with more than one vote: #{cards_with_more_than_one_vote.length}"
  #   puts ' No cards with more than one vote' unless not cards_with_more_than_one_vote.empty?
  # end
end
