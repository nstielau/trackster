require 'zip/zip'
require 'cobravsmongoose'
require 'open-uri'

class Track
  include MongoMapper::Document

  key :name, String
  key :distance
  key :active_time
  key :avg_page
  key :avg_speed
  key :created_utc
  key :motionx_id
  key :max_speed
  key :type
  key :saved_time_utc
  key :start_time_utc
  key :updated_utc
  key :formatted_avg_pace
  key :formatted_avg_speed
  key :formatted_date_time
  key :formatted_distance
  key :formatted_elapsed_time
  key :formatted_end_date
  key :formattted_location_finish_lat
  key :formattted_location_finish_lon
  key :formattted_location_start_lat
  key :formattted_location_start_lon
  key :formattted_max_alt
  key :formattted_max_speed
  key :formattted_min_alt
  key :formattted_start_date
  key :note, String
  timestamps!

  belongs_to :user

  def self.parse_track(url)
    file = open(url)
    result = read_motionx_zip_data(file.path)
    file.delete
    Track.create(result)
  end

  private

  def self.read_motionx_zip_data(file)
    result = nil
    Zip::ZipFile.open(file) do |zip_file|
     zip_file.each do |f|
       if f.to_s.match("xml")
         kml = f.get_input_stream.read
         hash = CobraVsMongoose.xml_to_hash(kml)
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