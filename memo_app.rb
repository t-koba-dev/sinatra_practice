# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

def open_file
  connection = PG::connect(:user => ENV['PG_USERNAME'], :password => ENV['PG_PASSWORD'], :dbname => "sinatra_practice_db")
  begin
    @memos = {}
    result = connection.exec("SELECT * FROM memos")
    result.each do |memo|
      @memos["#{memo['id']}"] = { 'title' => "#{memo['title']}", 'description' => "#{memo['description']}" }
    end
  ensure
    connection.finish
  end
end

def insert_db(id, title, description)
  connection = PG::connect(:user => ENV['PG_USERNAME'], :password => ENV['PG_PASSWORD'], :dbname => "sinatra_practice_db")
  begin
    connection.exec("INSERT INTO memos (id, title, description) VALUES ($1, $2, $3)", [id, title, description])
  ensure
    connection.finish
  end
end

def update_db(id, title, description)
  connection = PG::connect(:user => ENV['PG_USERNAME'], :password => ENV['PG_PASSWORD'], :dbname => "sinatra_practice_db")
  begin
    connection.exec("UPDATE memos SET id = $1, title = $2, description = $3 WHERE id = $1", [id, title, description])
  ensure
    connection.finish
  end
end

def delete_db(id)
  connection = PG::connect(:user => ENV['PG_USERNAME'], :password => ENV['PG_PASSWORD'], :dbname => "sinatra_practice_db")
  begin
    connection.exec("DELETE FROM memos WHERE id = $1", [id])
  ensure
    connection.finish
  end
end

def create(title, description)
  sample = []
  @memos.each_key { |memo| sample.push(memo.to_i) }
  insert_db((sample.max + 1), title, description)
end

def edit(title, description, memo_id)
  update_db(memo_id, title, description)
end

def destroy(memo_id)
  delete_db(memo_id)
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

get(%r{/.+}) do
  erb :'404'
end
