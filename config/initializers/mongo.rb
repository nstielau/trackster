if Rails.env == "development"
  MongoMapper.connection = Mongo::Connection.new
  MongoMapper.database = "motionxdb"
else
  MongoMapper.connection =Mongo::Connection.new("flame.mongohq.com", "21160")
  MongoMapper.database = "shopify-slideshows"
  MongoMapper.database.authenticate("nstielau", "manifest")
end