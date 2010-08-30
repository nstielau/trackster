require 'mongo_mapper'

if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new("127.0.0.1", 27017, :slave_ok => true)
  MongoMapper.database = "motionx_development"
elsif Rails.env == "test"
  MongoMapper.connection = Mongo::Connection.new("127.0.0.1", 27017, :slave_ok => true)
  MongoMapper.database = "motionxdb_test"
else
  MongoMapper.connection = Mongo::Connection.new("pearl.local.mongohq.com", "27029", :slave_ok => true)
  MongoMapper.database = "motionx_production"
  MongoMapper.database.authenticate(ENV['TRACKSTER_MONGOHQ_USERNAME'], ENV['TRACKSTER_MONGOHQ_PASSWORD'])
end