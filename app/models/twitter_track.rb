class TwitterTrack < Track
  include MongoMapper::Document

  key :twitter_id, String

  set_collection_name("twitter_tracks")

  def self.create_from_kmz_url(url)
    kmz_file = open(parse_motionx_url_from_gmaps_url(url))
    if kmz_file.is_a?(StringIO)
      tmp = Tempfile.new("kmz")
      tmp << kmz_file.read
      tmp.close
      kmz_file = tmp
    end
    track = TwitterTrack.new()
    track.read_motionx_zip_data(kmz_file.path)
    track.save
    track
  end
end