require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'GOPSlib'

$players = {}
$games = {}
$meet = []

before do headers "Content-Type" => "text/html; charset=utf-8" end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style, {:style => :compressed }
end

get '/' do
  @players = $players.values
  haml :welcome
end

post '/' do
  name = params[:name]
  player = $players.values.select{|p|p.name == name}.first
  if player.nil?
    player = Player.new(name)
    $players[player.id] = player
  end
  redirect "/dashboard/#{player.id}"
end

get '/update' do
  @game = $games[params[:gameid].to_i]
  @player = $players[params[:playerid].to_i]
  #kinda backwards, but if the current player
  #has to go, that means he should reload
  if @game.already_bid?(@player)
    return "false"
  else
    return "true"
  end
end

get '/dashboard/:id' do
  @reload = true
  @player = $players[params[:id].to_i]
  if @player
    games = $games.values
    @user_games = games.select{|g| g.players.has_key?(@player)}
  else
    return "Player not found."
  end
  haml :dashboard
end

get '/new-game/:player' do
  player = $players[params[:player].to_i]
  if $meet.empty?
    $meet << player.id
    redirect "/dashboard/#{player.id}"
  else
    redirect "/dashboard/#{player.id}" if $meet.include?(player.id)
    other_player = $players[$meet.pop]
    game = GOPS.new(player, other_player)
    $games[game.id] = game
    redirect "/game/#{game.id}/#{player.id}"
  end
end

get '/game/:game_id/:player' do
  @game = $games[params[:game_id].to_i]
  @player = $players[params[:player].to_i]
  @other_player = @game.players.keys.reject{|p| p == @player}.first if @player

  if @game && @player && @other_player
    if @game.finished?
      @reload = false
      haml :game_completed
    else
      @reload = @game.already_bid?(@player)
      haml :game
    end
  else
    return "game/player/opponent not found. Sorry."
  end
end

get '/game/:game_id/:player_id/:card' do
  game = $games[params[:game_id].to_i]
  player = $players[params[:player_id].to_i]
  success = game.place_bid(player, params[:card])
  redirect "/game/#{game.id}/#{player.id}"
end

helpers do
  def prettify(card)
    card.gsub("S", "&spades;").gsub("C", "&clubs;").gsub("H", "&hearts;").gsub("D", "&diams;").gsub("T", "10")
  end
  def font_color(card)
    return case card.suit
    when "Hearts"
      "red"
    when "Diamonds"
      "red"
    when "Spades"
      "black"
    when "Clubs"
      "black"
    end
  end
end
