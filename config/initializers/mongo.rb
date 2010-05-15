require 'mongo_mapper'

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionxdb"
else
  MongoMapper.connection = Mongo::Connection.new("flame.mongohq.com", "27066")
  MongoMapper.database = "motionx"
  MongoMapper.database.authenticate("nstielau", "manifest")
end