require 'sinatra'
require 'sinatra/reloader'
require 'json'

def open_file
  File.open("memos_data.json") { |file| @memos = JSON.load(file) }
end

def create(params)
  sample = []
  @memos.keys.each { |memo| sample.push(memo.to_i) }
  @memos[(sample.sort.last + 1).to_s] = { title: params["title"], description: params["description"] }
  File.open("memos_data.json", "w") { |file| file.write(JSON.pretty_generate(@memos)) }
end

get '/' do
  open_file
  erb :memos
end

get '/memo/new' do
  erb :memo_new
end

post '/memo/new' do
  open_file
  create(request.params)
  redirect '/'
end
