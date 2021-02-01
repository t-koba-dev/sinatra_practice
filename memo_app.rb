require 'sinatra'
require 'sinatra/reloader'

get '/' do
  @memos = ['メモ1', 'メモ2', 'メモ3']
  erb :memos
end
