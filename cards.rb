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
  def to_s
    @deck.collect{|c| c.to_s}.join(', ')
  end
end

class Card
  attr_reader :number, :suit, :value 
  def initialize(input)
    case input.class.to_s
    when "Fixnum"
        @suit = case input/13
        when 0; "Clubs"
        when 1; "Diamonds"
        when 2; "Hearts"
        when 3; "Spades"
        else; return nil;
        end
        @value = input%13 + 1
    when "Array"
    when "String"
    else return nil
    end
  end
  def to_s
    pretty_val = case @value
    when 13; "King"
    when 12; "Queen"
    when 11; "Jack"
    else; @value.to_s
    end
    pretty_val[0,1] + @suit[0,1]
  end
  def pretty
    pretty_val = case @value
    when 13; "King"
    when 12; "Queen"
    when 11; "Jack"
    else; @value.to_s
    end
    pretty_val + "of" + @suit
  end
end

class Player
  attr_accessor :cards, :name
  attr_reader :id, :score
  def initialize(name="player",cards=[])
    @name = name
    @cards = cards
    @id = (Time.now.to_f % 100000 * 10000).to_i
  end
  def sort_by(val)
    #if 
  end
  def score
    #pair
    #three
    
  end
  def pretty_score
  end
  def to_s
    #Player 2: 2S 3H 4D KH
  end
end