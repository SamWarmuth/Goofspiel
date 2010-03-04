require 'cards'
deck = Deck.new
players = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}

13.times {deck.draw}
players.each_value{|p| p.draw(13,deck)}
deck.shuffle_remaining

while(!deck.empty?)
  puts "Bidding On: " + deck.draw.to_s
  turn = []
  players.each_value do |p|
    puts p
    print "Which card will you use? "
    puts ""
    card = gets.chomp!
    card += p.hand.first.suit[0,1] if card.length == 1 #add suit
    begin
      card = Card.new(card)
      raise unless p.hand.include?(card)
    rescue
      redo
    end
    turn << card
    p.discard(card)
  end
  winning_card = turn.sort_by{|c| c.value}.reverse.first
  players[winning_card.suit].score += winning_card.value
  puts "Used " +turn.join(" and ") + " this turn, " + winning_card.suit + " wins." 
  puts "--------"
end
players.each_value do |p|
  puts p.name + ": " + p.score.to_s
end
winner = players.values.sort_by{|p|p.score}.last
puts winner.name + " Wins!"