require 'cards'
class GOPS
  attr_accessor :deck, :players
  attr_reader :bid_card
  def initialize(player1, player2)
    @deck = Deck.new
    @players = {player1 => "Diamonds", player2 => "Hearts"}
    @hands = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    @played = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    @won = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    13.times {@deck.draw}
    @players.each_value{|p| p.draw(13,deck)}
    @deck.shuffle_remaining
    @bid_card = @deck.draw
  end
  def place_bid(card)
    @current_bids ||= []
    if @current_bids.select{|c| c.suit == card.suit}.empty?
      @current_bids << card 
      @played[card.suit] << card
      score_round if @current_bids.length == @players.length
      return true
    else
      return false
    end
  end
  def score_round
    raise unless @current_bids.length == @players.length
    winning_card = @current_bids.sort_by{|c| c.value}.reverse.first
    @current_bids.clear
    @won[winning_card.suit] << winning_card
    
    @bid_card = @deck.draw unless @deck.empty?
  end
  def player_score(player)
    @won[@players[player]].inject{|sum,card| sum + card.value}
  end
  def game_finished
    @deck.empty? ? true : false
  end
end

=begin
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
=end