# frozen_string_literal: true

require 'sinatra'
require 'json'

set :enviroment, :production

def load_jsonfile
  File.open('memos.json', 'r') do |file|
    JSON.load_file(file) || []
  end
end

def write_to_jsonfile(memos)
  File.open('memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

def give_number_to_memos(memos)
  ids = memos.map { |memo_data| memo_data['id'] }
  ids.max.to_i + 1
end

def take_unique_memo(memos, params)
  memos.each do |memo_data|
   return memo_data if memo_data.value?(params[:id].to_i)
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
  @memos = load_jsonfile

  erb :top
end

get '/memos/create' do
  erb :new_memo
end

post '/memos/create' do
  memos = load_jsonfile
  new_memo_id = give_number_to_memos(memos)
  params['id'] = new_memo_id
  memos << params
  write_to_jsonfile(memos)

  redirect '/'
end

get '/memos/:id/show' do
  memos = load_jsonfile
  @id_memo_data = take_unique_memo(memos, params)

  erb :show_memo
end

delete '/memos/:id/show' do
  memos = load_jsonfile
  id_memo_data = take_unique_memo(memos, params)
  memos.delete_if { |memo_data| memo_data == id_memo_data }
  write_to_jsonfile(memos)

  redirect '/'
end

get '/memos/:id/edit' do
  memos = load_jsonfile
  @id_memo_data = take_unique_memo(memos, params)

  erb :edit_memo
end

patch '/memos/:id/edit' do
  memos = load_jsonfile
  edit_memo_data = params.delete_if { |key, _value| key == '_method' }
  edit_memo_data['id'] = edit_memo_data['id'].to_i

  i = 0
  arry_number = 0
  memos.each do |memo_data|
    arry_number = i if memo_data.value?(params[:id].to_i)
    i = + 1
  end

  memos[arry_number] = edit_memo_data
  write_to_jsonfile(memos)

  redirect '/'
end
