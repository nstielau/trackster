require 'mongo_mapper'

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionx_dev"
elsif Rails.env == "test"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionxdb_test"
else
  MongoMapper.connection = Mongo::Connection.new("pearl.local.mongohq.com", "27029")
  MongoMapper.database = "motionx_production"
  MongoMapper.database.authenticate(ENV['MONGOHQ_USERNAME'], ENV['MONGOHQ_PASSWORD'])
end