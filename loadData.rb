require 'csv'
require_relative './cards.rb'
require_relative './conversations.rb'
require_relative './test_data.rb'
require 'progress_bar'


filepath = "publicvotes.csv"

filesize = IO.readlines(filepath).size

bar0 = ProgressBar.new(filesize)
rows = []
CSV.foreach(filepath) do |row|
  rows << row
  bar0.increment!
end
puts ''

row_count = rows.length


users = []
cards = []
votes = []

bar1 = ProgressBar.new(row_count)
rows.each do |row|
  username, post_id, vote_value = row
  users << User.new(username)
  bar1.increment!
end
users = users.uniq
puts users.length
puts ''

bar2 = ProgressBar.new(row_count)
rows.each do |row|
  username, post_id, vote_value = row
  cards << Card.new(post_id)
  bar2.increment!
end
print 'removing duplicates...'
cards = cards.uniq
puts 'done'
puts cards.length

bar3 = ProgressBar.new(row_count)
rows.each do |row|
  username, post_id, vote_value = row
  user = users.select { |u| u.username == username }.first
  card = cards.select { |c| c.body == post_id }.first
  vote = Vote.new(card, vote_value)
  user.add_vote(vote)
  votes << vote
  bar3.increment!
end
puts votes.length
puts ''

cards_with_more_than_one_vote = cards.map do |c|
  votes.select {|v| v.card==c }.empty? ? nil : c
end
cards_with_more_than_one_vote = cards_with_more_than_one_vote.reject { |c| c.nil? }
puts " Number of cards with more than one vote: " + cards_with_more_than_one_vote.length.to_s
puts ' No cards with more than one vote' unless not cards_with_more_than_one_vote.empty?

batch_size = 5000
convos = []
cards.first(batch_size).each do |c|
  users_on_card = users.select do |u|
    not u.vote_on(c).nil?
  end
  convos << Conversation.new(users_on_card, c)
end

bar4 = ProgressBar.new(convos.length)
entropies = {}
chi2scores = {}
convos.each do |con|
  c = con.cards.first
  ent = con.card_entropy(c)
  chi = con.chi_squared_likelihood(c)
  entropies[c.body] = ent unless ent.nil?
  chi2scores[c.body] = chi unless chi.nil?
  bar4.increment!
end

non_nil_entropies = entropies.sort_by { |e| e[1] }
non_nil_chi2scores = chi2scores.sort_by { |s| s[1] }
# puts "Nil entropies eliminated: #{non_nil_entropies.length - entropies.length}"
# puts "Nil chi2 scores eliminated: #{non_nil_chi2scores.length - chi2scores.length}"

puts '  Entropies:'
puts 'lowest (good):'
non_nil_entropies.take(5).each {|e| puts e}
puts 'highest (bad):'
non_nil_entropies.reverse.take(5).each {|e| puts e}
puts '  Chi2 Scores:' unless non_nil_chi2scores.empty?
puts 'lowest (good):' unless non_nil_chi2scores.empty?
non_nil_chi2scores.take(5).each {|s| puts s}
puts 'highest (bad):' unless non_nil_chi2scores.empty?
non_nil_chi2scores.reverse.take(5).each {|s| puts s}
puts " Number of non-nil entropies: #{non_nil_entropies.length}"
puts " Number of non-nil chi2 scores: #{non_nil_chi2scores.length}"
puts ' All entropies were nil' unless not non_nil_entropies.empty?
puts ' All chi2 scores were nil' unless not non_nil_chi2scores.empty?

CSV.open("chi2Scores.csv", "w") do |csv|
  non_nil_chi2scores.each { |s| csv << s }
end

CSV.open("entropies.csv", "w") do |csv|
  non_nil_entropies.each { |s| csv << s }
end
