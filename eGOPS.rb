require 'rubygems'
require 'sinatra'
require 'haml'
require 'base64'
$players = {}
$games = {}

get '/' do
  haml :welcome
end

get '/dashboard/:id' do
  player = players.select{|p| p.id = params[:id]}.first
end

get '/game/:game_id' do
  decoded = Base64.decode64(params[:game_id]).split(" ")
  game = decoded[0]
  player = decoded[1]
end


__END__
@@layout
!!!
=yield

@@welcome
%h1 Welcome to Goofspiel
%p
  Please choose a username:
  ________