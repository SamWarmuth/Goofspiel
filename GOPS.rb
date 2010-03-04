require 'cards'

deck = Deck.new
players = [Player.new("Player 1"), Player.new("Player 2")]

13.times {deck.draw}
players.each{|p| p.draw(13,deck)}
deck.shuffle_remaining

while(!deck.empty?)
  puts deck.draw
  turn = []
  players.each do |p|
    puts p
    print "Which card will you use? "
    card = gets.chomp!
    card + p.hand.first.suit[0,1] if card.length == 1 #add suit
    puts card
    turn << p.discard(card)
  end
  puts "Used " +turn.join(" and ") + " this turn"
  puts "--------"
end

puts players.join("\n")
puts deck