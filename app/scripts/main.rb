# require 'csv'
# require_relative '../app/cards.rb'
# require_relative '../app/conversations.rb'
require_relative '../app/similarity.rb'
require_relative './load_csv.rb'
require 'progress_bar'

filepath = 'publicvotes.csv'

rows = LoadCsv.csv_rows(filepath, true)
all_cards = LoadCsv.cards_with_more_than_one_vote(rows)
all_users = LoadCsv.users_who_voted_on_cards(rows, all_cards)
convo = Conversation.new(all_users, all_cards)

bar4 = ProgressBar.new(convo.cards.length)
entropies = {}
[convo].each do |con|
  c = con.cards.first
  ent = con.card_entropy(c)
  entropies[c.body] = ent unless ent.nil?
  bar4.increment!
end

non_nil_entropies = entropies.sort_by { |e| e[1] }

puts '  Entropies:'
puts 'lowest (good):'
non_nil_entropies.take(5).each { |e| puts e }
puts 'highest (bad):'
non_nil_entropies.reverse.take(5).each { |e| puts e }
puts " Number of non-nil entropies: #{non_nil_entropies.length}"
puts ' All entropies were nil' if non_nil_entropies.empty?

CSV.open('entropies.csv', 'w') do |csv|
  non_nil_entropies.each { |s| csv << s }
end
