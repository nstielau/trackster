require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  def setup
    Track.all.each {|t| t.destroy}
  end

  test "can update from kmz file" do
    kmz_file = File.new("#{RAILS_ROOT}/test/fixtures/track006.kmz")
    track = Track.new(:kmz_file => kmz_file)
    track.save
    track.update_from_kmz!

    assert_equal 6096, track.distance
    assert_equal 1307, track.active_time
    assert_equal "1676", track.duration
    assert_equal "17.5 mph", track.formatted_max_speed
    assert_equal "Track 006", track.name
    assert_equal "3.79 miles", track.formatted_distance
    assert_equal "7.840000", track.max_speed
    assert_equal "8.1 mph", track.formatted_avg_speed
    assert_equal "4bfc04b0_c001", track.motionx_id
  end

  test "motionx_id is unique" do
    a = Track.create(:motionx_id => 123)
    b = Track.create(:motionx_id => 123)
    assert a.errors.empty?
    assert !b.errors.empty?
  end

  test "can parse Motionx url from gmaps url" do
    orig_url = "http://maps.google.com/?t=p&z=15&ll=37.78985595703125,-122.44378662109375&q=http://api.motionxlive.com/motionx-remote/api/gps/host/18af69f2-2794-43ca-8494-eae66efc958b"
    parsed_url = Track.parse_motionx_url_from_gmaps_url(orig_url)
    assert_equal parsed_url, "http://api.motionxlive.com/motionx-remote/api/gps/host/18af69f2-2794-43ca-8494-eae66efc958b"
  end

  test "can parse Motionx url from motionx url" do
    orig_url = "http://api.motionxlive.com/motionx-remote/api/gps/host/18af69f2-2794-43ca-8494-eae66efc958b"
    parsed_url = Track.parse_motionx_url_from_gmaps_url(orig_url)
    assert_equal parsed_url, orig_url
  end

end
# avg_pace: "2.749279",
# created_at: Tue, 01 Jun 2010 00:45:45 UTC +00:00,
# formatted_min_alt: "3 ft",
# formatted_end_date: "2010-05-25T17:39:08Z",
# saved_time_utc: "1274809149",
# formatted_max_alt: "79 ft",
# updated_utc: "1274809150",
# updated_at: Tue, 01 Jun 2010 00:45:45 UTC +00:00,
# motionx_id: "4bfc04b0_c001",
# created_utc: "1274809149",
# _id: $oid4c0458392bea865361000001,
# _type: "Track",
# formatted_start_date: "2010-05-25T17:11:12Z",
# formatted_location_start_lat: "37º 47' 22\" N",
# formatted_location_finish_lat: "37º 47' 04\" N",
# type: "0",
# avg_speed: "3.637317",
# note: "May 25, 2010 10:11 am",
# formatted_location_start_lon: "122º 26' 29\" W",
# formatted_date_time: "May 25, 2010 10:11 am",
# formatted_avg_pace: "07' 22\" per mile",
# formatted_location_finish_lon: "122º 23' 43\" W",
# formatted_elapsed_time: "27:56.0",
# start_time_utc: "1274807472"