require 'mongo_mapper'

class Meta
  include MongoMapper::Document

  key :last_twitter_update, String, :default => 0

  def self.get_instance
    raise "There should only ever be 1 meta" if Meta.count > 1
    return Meta.create if Meta.count == 0
    @meta ||= Meta.first
  end
end