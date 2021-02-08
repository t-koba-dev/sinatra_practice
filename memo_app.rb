# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

def open_file
  File.open('memos_data.json') { |file| @memos = JSON.parse(file.read) }
end

def write_file
  File.open('memos_data.json', 'w') { |file| file.write(JSON.pretty_generate(@memos)) }
end

def create(title, description)
  sample = []
  @memos.each_key { |memo| sample.push(memo.to_i) }
  @memos[(sample.max + 1).to_s] = { title: title, description: description }
  write_file
end

def edit(title, description, memo_id)
  @memos[memo_id] = { title: title, description: description }
  write_file
end

def destroy(memo_id)
  @memos.delete(memo_id)
  write_file
end

helpers do
  def link_to(url, text)
    %(<a href="#{url}">#{text}</a>)
  end
end

get '/' do
  open_file
  erb :memos
end

get '/memo/new' do
  erb :memo_new
end

post '/memo' do
  open_file
  create(escape_html(params['title']), escape_html(params['description']))
  redirect '/'
end

get(%r{/memo/([0-9]+)}) do
  open_file
  @memo = [params['captures'].first, @memos[params['captures'].first]]
  erb :memo_show
end

get(%r{/memo/([0-9]+)/edit}) do
  open_file
  @memo = [params['captures'].first, @memos[params['captures'].first]]
  erb :memo_edit
end

patch(%r{/memo/([0-9]+)}) do
  open_file
  edit(escape_html(params['title']), escape_html(params['description']), params['captures'].first)
  redirect '/'
end

delete(%r{/memo/([0-9]+)}) do
  open_file
  destroy(params['captures'].first)
  redirect '/'
end

not_found do
  erb :'404'
end
