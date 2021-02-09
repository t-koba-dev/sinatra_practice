# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

def connect_to_database
  PG.connect(user: ENV['PG_USERNAME'], password: ENV['PG_PASSWORD'], dbname: 'sinatra_practice_db')
end

def load_memos_from_database
  connection = connect_to_database
  begin
    @memos = {}
    result = connection.exec('SELECT * FROM memos')
    result.each do |memo|
      @memos[memo['id'].to_s] = { title: memo['title'], description: memo['description'] }
    end
  ensure
    connection.finish
  end
end

def insert_record(id, title, description)
  connection = connect_to_database
  begin
    connection.prepare('insert_plan', 'INSERT INTO memos (id, title, description) VALUES ($1, $2, $3)')
    connection.exec_prepared('insert_plan', [id, title, description])
  ensure
    connection.finish
  end
end

def update_record(id, title, description)
  connection = connect_to_database
  begin
    connection.prepare('update_plan', 'UPDATE memos SET id = $1, title = $2, description = $3 WHERE id = $1')
    connection.exec_prepared('update_plan', [id, title, description])
  ensure
    connection.finish
  end
end

def delete_record(id)
  connection = connect_to_database
  begin
    connection.prepare('delete_plan', 'DELETE FROM memos WHERE id = $1')
    connection.exec_prepared('delete_plan', [id])
  ensure
    connection.finish
  end
end

def create(title, description)
  sample = []
  @memos.each_key { |memo| sample.push(memo.to_i) }
  insert_record((sample.max + 1), title, description)
end

def edit(title, description, id)
  update_record(id, title, description)
end

def destroy(id)
  delete_record(id)
end

helpers do
  def link_to(url, text)
    %(<a href="#{url}">#{text}</a>)
  end
end

get '/' do
  load_memos_from_database
  erb :memos
end

get '/memo/new' do
  erb :memo_new
end

post '/memo' do
  load_memos_from_database
  create(escape_html(params['title']), escape_html(params['description']))
  redirect '/'
end

get(%r{/memo/([0-9]+)}) do
  load_memos_from_database
  @memo = [params['captures'].first, @memos[params['captures'].first]]
  erb :memo_show
end

get(%r{/memo/([0-9]+)/edit}) do
  load_memos_from_database
  @memo = [params['captures'].first, @memos[params['captures'].first]]
  erb :memo_edit
end

patch(%r{/memo/([0-9]+)}) do
  load_memos_from_database
  edit(escape_html(params['title']), escape_html(params['description']), params['captures'].first)
  redirect '/'
end

delete(%r{/memo/([0-9]+)}) do
  load_memos_from_database
  destroy(params['captures'].first)
  redirect '/'
end

get(%r{/.+}) do
  erb :'404'
end
