# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pg'

set :enviroment, :production

FILE_NAME = 'memos.json'

def connect_databese
  PG.connect(dbname: 'memosdata')
end

def load_databese
  connect_databese.exec('SELECT * FROM memos ORDER BY id ASC')
end

def give_number_to_memos(memos)
  memos.map { _1['id'] }.max.to_i + 1
end

def find_memo(memos, params)
  memos.each do |memo|
    return memo if memo.value?(params[:id])
  end
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = load_databese

  erb :top
end

get '/memos/create' do
  erb :new_memo
end

post '/memos/create' do
  memos = load_databese

  id =  give_number_to_memos(memos)
  name = params[:name]
  message = params[:message]

  sql = 'INSERT INTO memos (id, name, message) VALUES ($1, $2, $3)'
  connect_databese.exec_params(sql, [id, name, message])

  redirect '/'
end

get '/memos/:id/show' do
  memos = load_databese
  @memo = find_memo(memos, params)

  erb :show_memo
end

delete '/memos/:id/show' do
  memos = load_databese

  sql = 'DELETE FROM Memos WHERE id = $1 '
  connect_databese.exec_params(sql, [find_memo(memos, params)['id']])

  redirect '/'
end

get '/memos/:id/edit' do
  memos = load_databese
  @memo = find_memo(memos, params)

  erb :edit_memo
end

patch '/memos/:id/edit' do
  id = params[:id].to_i
  name = params[:name]
  message = params[:message]

  sql = 'UPDATE Memos SET name = $1, message = $2 WHERE id = $3'
  connect_databese.exec_params(sql, [name, message, id])

  redirect '/'
end
