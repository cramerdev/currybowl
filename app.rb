require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongo_mapper'

configure do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOHQ_URL']}}, 'production')

  if development?
    MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
    MongoMapper.database = "curry_bowl"
  end
end

class Bowl
  include MongoMapper::Document

  many :servings

  timestamps!
end

class Serving
  include MongoMapper::Document

  belongs_to :bowl

  key :request, String
  key :bowl_id, ObjectId

  timestamps!
end

get '/' do
  erb :index
end

get '/new' do
  bowl = Bowl.new
  bowl.save

  redirect "/#{bowl.id}"
end

get '/:id' do
  id = params.fetch('id')
  @bowl = Bowl.find(id) || Bowl.new(id: id)

  unless @bowl.id
    @bowl.save
  end

  erb :bowl
end

post '/:id' do
  id = params.fetch('id')
  @bowl = Bowl.find(id)

  @serving = @bowl.servings.create(request: params.to_s)
end
