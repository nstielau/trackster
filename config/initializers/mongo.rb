require 'mongo_mapper'

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionx_dev"
elsif Rails.env == "test"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionxdb_test"
else
  MongoMapper.connection = Mongo::Connection.new("flame.mongohq.com", "27066")
  MongoMapper.database = "motionx"
  MongoMapper.database.authenticate("nstielau", "manifest")
end