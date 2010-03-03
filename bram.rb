require 'cards'

deck = Deck.new
deck.shuffle

player_one = Array.new(8) {deck.draw}
player_two = Array.new(8) {deck.draw}

puts "Player One: " + player_one.join(", ")
puts "Player Two: " + player_two.join(", ")

discards = [["Player One", player_one], ["Player 2", player_two]]

discards.map! do |player|
  indices = []
  while indices.length != 4
    puts player[0] + ", pick four cards to KEEP (e.g. '0' to save #{player[1][0]})?"
    indices = gets.chomp!.split(' ').map{|i| i.to_i}
  end
  
  discard = []
  indices.sort.reverse.each {|i| discard << player[1].delete_at(i)}
  discard
end
puts discards.length
puts "Player 1: " + player_one.join(", ") + " - " +  discards[1].join(", ")
puts "Player 2: " + player_two.join(", ") + " - " +  discards[0].join(", ")