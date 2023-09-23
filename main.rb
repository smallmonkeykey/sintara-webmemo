# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'pg' 

set :enviroment, :production

FILE_NAME = 'memos.json'

def connect_databese
  PG.connect( dbname: 'memosdata' )
end

def load_databese
  connect_databese.exec( "SELECT * FROM memos" )
end

def give_number_to_memos(memos)
  memos.map { _1['id'] }.max.to_i + 1
end

def take_unique_memo(memos, params)
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

  sql = "INSERT INTO memos (id, name, message) VALUES ('#{id}', '#{name}','#{message}');"
  connect_databese.exec_params(sql)

  redirect '/'
end

get '/memos/:id/show' do
  memos = load_databese
  @memo = take_unique_memo(memos, params)

  erb :show_memo
end

delete '/memos/:id/show' do
  memos = load_jsonfile
  memos.delete_if { |memo| memo == take_unique_memo(memos, params) }
  write_to_jsonfile(memos)

  redirect '/'
end

get '/memos/:id/edit' do
  memos = load_jsonfile
  @memo = take_unique_memo(memos, params)

  erb :edit_memo
end

patch '/memos/:id/edit' do
  memos = load_jsonfile

  edited_memo = {
    name: params[:name],
    message: params[:message],
    id: params[:id].to_i
  }

  index = memos.find_index { _1['id'] == edited_memo[:id] }
  memos[index] = edited_memo
  write_to_jsonfile(memos)

  redirect '/'
end
