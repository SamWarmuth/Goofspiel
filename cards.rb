#A deck of cards. Theoretically should be usable by any program that needs cards.
#Each deck is an array of cards
#Each card is a two-element array [value, suit]
#Suits "Hearts", "Spades", "Clubs", "Diamonds"

class Deck
  attr_reader :deck, :drawn
  def initialize
    @deck = Array.new(52){|i| Card.new(51-i)}
    @drawn = []
  end
  def draw
    card = @deck.pop
    @drawn << card
    card
  end
  def shuffle
    @deck += @drawn
    @deck = @deck.sort_by{rand}
  end
  def shuffle_remaining
    @deck = @deck.sort_by{rand}
  end
  def inspect; self.to_s; end
  def to_s
    @deck.collect{|c| c.to_s}.join(', ')
  end
end

class Card
  attr_reader :number, :value 
  include Comparable
  Suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
  def initialize(input)
    case input.class.to_s
    when "Fixnum"
        @suit = input/13
        @value = input%13 + 2
    when "Array"
    when "String"
    else return nil
    end
  end
  def <=>(other)
    @value*100+@suit
  end
  def suit
    Suits[@suit]
  end
  def inspect; self.to_s; end
  def to_s
    pretty_val = case @value
    when 14; "Ace"
    when 13; "King"
    when 12; "Queen"
    when 11; "Jack"
    else; @value.to_s
    end
    pretty_val[0,1] + Suits[@suit][0,1]
  end
  def pretty
    pretty_val = case @value
    when 13; "King"
    when 12; "Queen"
    when 11; "Jack"
    else; @value.to_s
    end
    pretty_val + " of " + Suits[@suit]
  end
end

class Player
  attr_accessor :hand, :name
  attr_reader :id, :rank
  def initialize(name="Player",cards=[])
    @name = name
    @hand = cards
    @id = (Time.now.to_f % 100000 * 10000).to_i
  end
  def add_cards(cards)
    cards = Array(cards) # turn '5' into [5]
    @hand += cards
    rank
  end
  def draw(number, deck)
    number.times{@hand << deck.draw}
  end
  def discard(card)
    case card.class.to_s
    when "String"
      @hand.delete_if{|c| c.to_s.downcase == card.downcase}
    end
  end
  def sort_by(tag)
    #case tag
    #suit, value
  end
  def rank
    by_value = @hand.group_by{|c|c.value}
    by_suit = @hand.group_by{|c|c.suit}
    
    #eventually I should only find the ones that matter
    pair =  by_value.select{|key,val| val.length == 2}
    three =  by_value.select{|key,val| val.length == 3}
    four = by_value.select{|key,val| val.length == 4}
    flush = by_suit.select{|key,val| val.length >= 5}
    straight = (2..10).map{|i| by_value.has_keys?((i..i+4)) ? (print "YAY #{i}!") : nil}.compact!
    puts straight.inspect
    puts by_value.has_keys?((6..10))
    
    
    # so, check for flushes & straights
    # if both, check for straight flush (hard) -- sort flush?
    # 4 of a kind?
    # get pairs & threes.
    # Both? Full House, find the biggest
    # Find highest triple
    # Two Pair?
    # Find highest pair
    # Find highest card


  end
  def pretty_score
  end
  def to_s
    @name + " " + @hand.join(" ")
    #Player_name: 2S 4H 4D KH 3S (Pair of 4s)
  end
end

class Hash
  def has_keys?(*keys)
    keys.select{|k,v| !self.include?(k)}.empty?
  end
end

m = {:a => 1, :b => 2}