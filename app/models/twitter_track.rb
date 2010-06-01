class TwitterTrack < Track
  include MongoMapper::Document

  key :twitter_id, String

  set_collection_name("twitter_tracks")
end