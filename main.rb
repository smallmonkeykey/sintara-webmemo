# frozen_string_literal: true

require 'sinatra'
require 'json'

set :enviroment, :production

def load_jsonfile
  if FileTest.zero?('memos.json')
     File.open('memos.json', 'w') do |file|
      file << []
    end
  end

  File.open('memos.json', 'r') do |file|
    JSON.parse(file.read)
  end
end

def write_to_jsonfile(memos)
  File.open('memos.json', 'w') do |file|
    JSON.dump(memos, file)
  end
end

def give_number_to_memos(memos)
  maximum_memo = memos.max_by { |a| a['id'] } || {}
  maximum_memo['id'].to_i + 1
end

def take_unique_memo(memos, params)
  memos.each do |memo|
    return memo if memo.value?(params[:id].to_i)
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
  unless FileTest.exist?('memos.json')
    File.open('memos.json', 'w') do |file|
      file << []
    end
  end
  @memos = load_jsonfile

  erb :top
end

get '/memos/create' do
  erb :new_memo
end

post '/memos/create' do
  memos = load_jsonfile
  memos << {
    "name": params[:name],
    "message": params[:message],
    "id": give_number_to_memos(memos)
  }
  write_to_jsonfile(memos)

  redirect '/'
end

get '/memos/:id/show' do
  memos = load_jsonfile
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

  index = memos.find_index { |memo| memo['id'] == edited_memo[:id] }
  memos[index] = edited_memo
  write_to_jsonfile(memos)

  redirect '/'
end
