require 'sinatra'
require 'sinatra/reloader'

get '/' do
  @memos = ['メモ1', 'メモ2', 'メモ3']
  erb :memos
end

get '/memo/new' do
  erb :memo_new
end
