require 'sinatra'
require 'sinatra/reloader'

get '/' do
  erb :memos
end
