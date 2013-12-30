require 'sinatra'
require 'slim'
require 'coffee-script'

# require "sinatra/reloader" if development?

require './lib/pandora'

get '/pandora' do
  @@pandora ||= Pandora.new
  slim :pandora
end

get '/pandora/song' do
  @@pandora.song
end

get '/pandora/station' do
  @@pandora.station
end

get '/pandora/explanation' do
  @@pandora.explanation
end

get '/pandora/upcoming_songs' do
  content_type :json
  @@pandora.upcoming_songs.to_json
end

get '/pandora/:cmd' do
  @@pandora.send_command(params[:cmd]) || "ok (#{params[:cmd]})"
  redirect("/pandora")
end

