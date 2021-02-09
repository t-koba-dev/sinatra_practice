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

def select_one_record(id)
  connection = connect_to_database
  begin
    result = connection.exec('SELECT * FROM memos WHERE id = $1', [id])
  ensure
    connection.finish
  end
  result.first
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
    connection.prepare('update_plan', "UPDATE memos SET title = $1, description = $2 WHERE id = #{id}")
    connection.exec_prepared('update_plan', [title, description])
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

def edit(id, title, description)
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
  id = params['captures'].first
  memo = select_one_record(id)
  @memo_id = memo['id']
  @memo = { title: memo['title'], description: memo['description'] }
  erb :memo_show
end

get(%r{/memo/([0-9]+)/edit}) do
  id = params['captures'].first
  memo = select_one_record(id)
  @memo_id = memo['id']
  @memo = { title: memo['title'], description: memo['description'] }
  erb :memo_edit
end

patch(%r{/memo/([0-9]+)}) do
  load_memos_from_database
  edit(params['captures'].first, escape_html(params['title']), escape_html(params['description']))
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
