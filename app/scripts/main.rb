require_relative '../scripts/init_db.rb'
require_relative './load_csv.rb'
require_relative './analysis.rb'

filepath = 'app/scripts/publicvotes.csv'

rows = LoadCsv.csv_rows(filepath, true)
# rows = [
#   %w[abc123 t9_barfig 1],
#   %w[abc123 t9_barfpu 1],
#   %w[abc123 t9_binsop 1],
#   %w[blogmonster t9_barfig 1],
#   %w[blogmonster t9_binsop 1],
#   ['blogmonster', 't9_barfpu', '0'],
#   %w[blogmonster t9_baondig 1],
#   %w[wrongwarp t9_biiviig 1]
# ].freeze

LoadCsv.users(rows, true)
LoadCsv.cards(rows, true)
LoadCsv.votes(rows, true)

first_order = Analysis.ordered_cards.map(&:body)
p first_order.first(5)

all_votes = Vote.all

all_votes.each {|v| v.attitude == nil}
all_votes.shuffle.each(&:cast)

second_order = Analysis.ordered_cards.map(&:body)
p second_order.first(5)

p first_order == second_order
