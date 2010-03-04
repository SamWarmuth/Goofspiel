#A deck of cards. Theoretically should be usable by any program that needs cards.

class Deck
  attr_reader :deck, :discard
  def initialize
    @deck = Array.new(52){|i| Card.new(51-i)}
    @discard = []
  end
  def draw
    card = @deck.pop
    @discard << card
    card
  end
  def shuffle
    @deck += @discard
    @deck = @deck.sort_by{rand}
  end
  def shuffle_remaining
    @deck = @deck.sort_by{rand}
  end
  def empty?
    @deck.empty?
  end
  def to_s
    @deck.collect{|c| c.to_s}.join(', ')
  end
end

class Card
  attr_reader :value 
  include Comparable
  Suits = ["Clubs", "Diamonds", "Hearts", "Spades"]
  def initialize(input)
    case input.class.to_s
    when "Fixnum"
        @suit = input/13
        @value = input%13 + 2
    when "String"
      @suit = Suits.map{|s| s[0,1].downcase}.index(input[1,1].downcase)
      @value = case input[0,1].downcase
      when "a"; 14
      when "k"; 13
      when "q"; 12
      when "j"; 11
      when "t"; 10
      else; input[0,1].to_i
      end
    else return nil
    end
  end
  def <=>(other)
    @value <=> other.value #suit *not* taken into account
  end
  def suit
    Suits[@suit]
  end
  def to_s
    pretty_val = case @value
    when 14; "Ace"
    when 13; "King"
    when 12; "Queen"
    when 11; "Jack"
    when 10; "Ten"
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
  attr_reader :id, :rank, :top_hand
  def initialize(name="Player",cards=[])
    @name = name
    @hand = cards
    @id = (Time.now.to_f % 100000 * 10000).to_i
  end
  def add_cards(*cards)
    cards = Array(cards)
    @hand += cards
    find_rank
  end
  def draw(number, deck)
    number.times{@hand << deck.draw}
    find_rank
  end
  def discard(card)
    case card.class.to_s
    when "String"
      drawn = @hand.select{|c| c.to_s.downcase == card.downcase}
      @hand.delete(drawn)
      return drawn
    end
  end
  def sort_by(tag)
    #case tag
    #suit, value
  end
  def rank
    @rank
  end
  def find_rank
    
    by_value = @hand.group_by{|c|c.value} # creates hash {2 => [2C, 2D], 3 => [3H, 3S, 3C]...}
    by_suit = @hand.group_by{|c|c.suit}   # creates hash {"Diamonds" => [2D, 3D, 8D], "Clubs" => [2C]...}
    
    #eventually I should only find the ones that matter
    pair =  by_value.select{|key,val| val.length == 2}.map{|a,b| b.sort.reverse}.sort_by{|n| n[0].value}.reverse
    three =  by_value.select{|key,val| val.length == 3}.map{|a,b| b.sort.reverse}.sort_by{|n| n[0].value}.reverse.first
    four = by_value.select{|key,val| val.length == 4}.map{|a,b| b.sort.reverse}.sort_by{|n| n[0].value}.reverse.first
    flush = by_suit.select{|key,val| val.length >= 5}.map{|a,b| b.sort.reverse}.sort_by{|n| n[0].value}.reverse.first
    high_cards = @hand.sort.reverse
    
    #straight = (2..10).map{|i| by_value.has_keys?((i..i+4)) ? (print "#{i}...#{i+4}!") : nil}.compact!
    if !four.nil?
      @top_hand = four
      @rank = "Four of a Kind"
    elsif !three.nil? && !pair.empty?
      @top_hand = three + pair[0]
      @rank = "Full House"
    elsif !flush.nil?
      @top_hand = flush[0,5]
      @rank = "Flush"
    elsif !nil.nil?
      puts " (Straight) Not Implemented."
    elsif !three.nil?
      @top_hand = three
      @rank = "Three of a Kind"
    elsif pair.length > 1
      @top_hand = pair[0] + pair[1]
      @rank = "Two Pair"
    elsif !pair.first.nil?
      @top_hand = pair.first
      @rank = "Pair"
    else
      @top_hand = high_cards[0,5]
      @rank = "Garbage"
    end
    while (@top_hand.length < 5 && !high_cards.empty?)
      c = high_cards.delete_at(0)
      @top_hand << c if !@top_hand.include?(c)
    end
    return @top_hand

  end
  def to_s
    @name + ": " + @hand.join(" ")
  end
end