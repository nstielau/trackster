require 'zip/zip'
require 'cobravsmongoose'
require 'open-uri'
require 'uri'

class Track
  include MongoMapper::Document
  include Griddle::HasGridAttachment

  key :name, String
  key :distance, Fixnum
  key :active_time, Fixnum
  key :avg_pace
  key :avg_speed
  key :created_utc
  key :motionx_id
  key :max_speed
  key :type
  key :saved_time_utc
  key :start_time_utc
  key :updated_utc
  key :formatted_avg_pace, String
  key :formatted_avg_speed, String
  key :formatted_date_time, String
  key :formatted_distance, String
  key :formatted_elapsed_time, String
  key :formatted_end_date, String
  key :formatted_location_finish_lat, String
  key :formatted_location_finish_lon, String
  key :formatted_location_start_lat, String
  key :formatted_location_start_lon, String
  key :formatted_max_alt, String
  key :formatted_max_speed, String
  key :formatted_min_alt, String
  key :formatted_start_date, String
  key :note, String
  timestamps!

  has_grid_attachment :kmz_file
  has_grid_attachment :gpx_file

  belongs_to :user

  validates_uniqueness_of :motionx_id

  def self.create_from_kmz_url(url)
    url = parse_motionx_url_from_gmaps_url(url) if url.match("maps.google.com")
    track = self.new(:kmz_file => open(url))
    track.save
    track.update_from_kmz!
    track
  end

  def self.create_from_share_email(gpx_file, kmz_file)
    track = self.create(:kmz_file => kmz_file, :gpx_file => gpx_file)
    track.update_from_kmz!
    track
  end

  def unformatted_location_start_lon
    parts = formatted_location_start_lon.gsub(/[\D|\s]/, " ").split(/\s/).reject{|x| x == ""}
    a = parts[0].to_f + (parts[1].to_f/60.0) + (parts[2].to_f/60.0/60.0)
    a = a.to_f * -1 if formatted_location_start_lon.match("W")
    a.to_s
  end

  def unformatted_location_start_lat
    parts = formatted_location_start_lat.gsub(/[\D|\s]/, " ").split(/\s/).reject{|x| x == ""}
    a = parts[0].to_f + (parts[1].to_f/60.0) + (parts[2].to_f/60.0/60.0)
    a = a.to_f * -1 if formatted_location_start_lat.match("S")
    a.to_s
  end

  def update_from_kmz!
    tmp = Tempfile.new("kmz")
    tmp <<  kmz_file.file.read
    tmp.close
    result = read_motionx_zip_data(tmp.path)
    tmp.delete
    update_attributes(result)
  end

  private

  def self.parse_motionx_url_from_gmaps_url(url)
    URI::parse(url).query.split("&").select{|x| x.match("q=")}[0].sub("q=", "")
  end

  def read_motionx_zip_data(file)
    result = nil
    Rails.logger.error("File: #{file}")
    Zip::ZipFile.open(file) do |zip_file|
     zip_file.each do |f|
       if f.to_s.match("xml")
         kml = f.get_input_stream.read
         hash = CobraVsMongoose.xml_to_hash(kml)
         raise TrackError.new("KMZ file is for a waypoint, not a track.") if hash["waypoint"]
         result = {
           :duration => hash["track"]["@duration"],
           :distance => hash["track"]["@distance"],
           :name => hash["track"]["name"]["$"],
           :active_time => hash["track"]["@activeTime"],
           :avg_pace => hash["track"]["@avgPace"],
           :avg_speed =>hash["track"]["@avgSpeed"],
           :created_utc => hash["track"]["@createdUtc"],
           :motionx_id => hash["track"]["@id"],
           :max_speed => hash["track"]["@maxSpeed"],
           :type => hash["track"]["@type"],
           :saved_time_utc => hash["track"]["@savedTimeUtc"],
           :start_time_utc => hash["track"]["@startTimeUtc"],
           :updated_utc => hash["track"]["@updatedUtc"],
           :formatted_avg_pace => hash["track"]["formattedAvgPace"]["$"],
           :formatted_avg_speed => hash["track"]["formattedAvgSpeed"]["$"],
           :formatted_date_time => hash["track"]["formattedDateTime"]["$"],
           :formatted_distance => hash["track"]["formattedDistance"]["$"],
           :formatted_elapsed_time => hash["track"]["formattedElapsedTime"]["$"],
           :formatted_end_date => hash["track"]["formattedEndDate"]["$"],
           :formatted_location_finish_lat => hash["track"]["formattedLocationFinishLat"]["$"],
           :formatted_location_finish_lon => hash["track"]["formattedLocationFinishLon"]["$"],
           :formatted_location_start_lat => hash["track"]["formattedLocationStartLat"]["$"],
           :formatted_location_start_lon => hash["track"]["formattedLocationStartLon"]["$"],
           :formatted_max_alt => hash["track"]["formattedMaxAlt"]["$"],
           :formatted_max_speed => hash["track"]["formattedMaxSpeed"]["$"],
           :formatted_min_alt => hash["track"]["formattedMinAlt"]["$"],
           :formatted_start_date => hash["track"]["formattedStartDate"]["$"],
           :note => hash["track"]["note"]["$"]
         }
       end
     end
    end
    result
  end
end

class TrackError < StandardError; end