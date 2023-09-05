require 'sinatra'
require 'json'

set :enviroment, :production


def load_jsonfile
  File.open("memos.json", "r") do |file|
    JSON.load(file) || []
  end
end

def write_to_jsonfile(memos_data)
  File.open("memos.json", "w") do |file|
    JSON.dump(memos_data, file)
  end
end

def give_number_to_memos_data(memos_data, params)
	ids = memos_data.map {|memo_data| memo_data['id']}
	ids.max.to_i + 1
end

def take_unique_memo(memos_data, params)
	id_memo_data = {}

	memos_data.each do |memo_data|
	 id_memo_data = memo_data if memo_data.value?(params[:id].to_i)
	end

	id_memo_data
end


get '/' do
	@memos_date = load_jsonfile

    erb :top
end

get '/memos/create' do
    erb :new_memo
end

post '/memos/create' do
	memos_data = load_jsonfile
	new_memo_id = give_number_to_memos_data(memos_data, params)
	params['id'] = new_memo_id
	memos_data << params
	write_to_jsonfile(memos_data)

	redirect '/'
end

get '/memos/:id/show' do
	memos_data = load_jsonfile
  @id_memo_data = take_unique_memo(memos_data, params)

	erb :show_memo
end

delete '/memos/:id/show' do
	memos_data = load_jsonfile
	id_memo_data = take_unique_memo(memos_data, params)
	memos_data.delete_if{|memo_data| memo_data == id_memo_data }
	write_to_jsonfile(memos_data)
	
	redirect '/'

end

get '/memos/:id/edit' do
	memos_data = load_jsonfile
	@id_memo_data = take_unique_memo(memos_data, params)

	erb :edit_memo
end
