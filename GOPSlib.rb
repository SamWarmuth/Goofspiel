require 'cards'

class GOPS
  attr_accessor :deck, :players
  attr_reader :bid_card, :current_bids, :id
  def initialize(player1, player2)
    @id = (Time.now.to_f % 100000 * 10000).to_i
    @deck = Deck.new
    @players = {player1 => "Diamonds", player2 => "Hearts"}
    @hands = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    @played = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    @won = {"Diamonds" => Player.new("Diamonds"), "Hearts" => Player.new("Hearts")}
    @current_bids ||= []
    13.times {@deck.draw}
    @hands.each_value{|p| p.draw(13,deck)}
    @deck.shuffle_remaining
    @bid_card = Array(@deck.draw)
  end
  def hand(player)
    @hands[@players[player]].hand
  end
  def played(player)
    @played[@players[player]].hand
  end
  def won(player)
    @won[@players[player]].hand
  end
  def place_bid(player, card)
    begin
      card = Card.new(card)
      raise unless (@players[player] == card.suit)&&(hand(player).include?(card))
    rescue
      return false
    end
    if @current_bids.select{|c| c.suit == card.suit}.empty?
      @current_bids << card 
      @hands[card.suit].discard(card)
      @played[card.suit].hand << card
      score_round if @current_bids.length == @players.length
      return true
    else
      return false
    end
  end
  def score_round
    raise unless @current_bids.length == @players.length
    bids = @current_bids.sort_by{|c| c.value}.reverse
    if bids[0].value == bids[1].value
      @current_bids.clear
      @bid_card << @deck.draw
    else
      winning_card = bids.first
      @current_bids.clear
      @won[winning_card.suit].hand += @bid_card
      @bid_card = nil
      @bid_card = Array(@deck.draw) unless @deck.empty?
    end
  end
  def last_bid(player)
    return nil if played(player).last.nil?
    return played(player).last unless @current_bids.include?(played(player).last)
    return played(player)[-2]
  end
  def already_bid?(player)
    hand = @played[@players[player]].hand
    hand = @hands[@players[player]].hand if hand.empty? #one of these will have a card
    !@current_bids.select{|c| c.suit == hand[0].suit}.empty?
  end
  def score(player)
    won(player).inject(0){|sum,card| sum + card.value}
  end
  def finished?
    (@deck.empty?&&@bid_card.nil?) ? true : false
  end
end