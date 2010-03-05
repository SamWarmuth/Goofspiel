require 'rubygems'
require 'sinatra'
require 'haml'
require 'GOPSlib'
$players = {}
$games = {}
$meet = []

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

get '/dashboard/:id' do
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
  @other_player = @game.players.keys.reject{|p| p == @player}.first
  if @game&&@player&&@other_player
    if @game.finished?
      haml :game_completed
    else
      haml :game
    end
  else
    return "game/player/opponent not found. Sorry."
  end
end

get '/game/:game_id/:player/:card' do
  game = $games[params[:game_id].to_i]
  player = $players[params[:player].to_i]
  success = game.place_bid(player, params[:card])
  redirect "/game/#{game.id}/#{player.id}"
end



__END__
@@layout
!!!
%title Goofspiel.com
%body
  =yield

@@welcome
%h1
  Welcome to Goofspiel
  %a{:href => "http://en.wikipedia.org/wiki/Goofspiel" :style => "font-size: 50%"} (what's Goofspiel?)
%form{:method => "POST", :action => "/"}
  %label Please choose a username:
  %input{:name => "name", :value => "", :type => "text", :size => "20"}
%h2 Current Players:
%p
  =@players.map{|p| p.name}.join("\n")

@@dashboard
%h2 Hi there #{@player.name}
= "You're waiting for someone to play with." if $meet.include?(@player.id)
-my_games = $games.values.select{|g| g.players.keys.include?(@player)}
-unless my_games.empty?
  %h2 Your Games
  %p
    -my_games.each do |game|
      %a{:href => "/game/#{game.id}/#{@player.id}"}
        Game Against 
        =game.players.keys.reject{|p| p == @player}.first.name
      
%p
  %a{:href => "/new-game/#{@player.id}"} New Game

@@game
%h3 #{@player.name}, you're playing against #{@other_player.name}
%p Bidding on: #{@game.bid_card.join(" ")}
%p
  -if @game.already_bid?(@player)
    Waiting for #{@other_player.name}'s bid
    %br
    Your Cards:
    %br
    = @game.hand(@player).join(" ")
  -else
    Your Cards:
    %br
    -@game.hand(@player).each do |card|
      %a{:href => "/game/#{@game.id}/#{@player.id}/#{card.to_s}"}= card.to_s
  -unless @game.won(@player).empty?
    %p
      So far, you've won:
      =@game.won(@player).join(" ") 
      
@@game_completed
-if @game.score(@player) > @game.score(@other_player)
  %h1 Congratulations, you won!
-elsif @game.score(@player) < @game.score(@other_player)
  %h1 Better luck next time.
-else
  %h1 Like kissing your <i>Sister</i>.
%h2 #{@player.name}: #{@game.score(@player)}
%h2 #{@other_player.name}: #{@game.score(@other_player)}

  
