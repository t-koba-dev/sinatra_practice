require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/' do
  File.open("memos_data.json") { |file| @memos = JSON.load(file) }
  erb :memos
end

get '/memo/new' do
  erb :memo_new
end

post '/memo/new' do
  redirect '/'
end
