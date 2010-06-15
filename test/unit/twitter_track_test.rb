require 'test_helper'

class TwitterTrackTest < ActiveSupport::TestCase
  def setup
    TwitterTrack.all.each {|t| t.destroy}
  end

  test "can aggregate total distance, 0 with no data" do
    assert_equal TwitterTrack.total_distance, 0
  end

  test "can aggregate total distance with data" do
    TwitterTrack.create(:created_utc => Time.now.to_i, :distance => 100)
    TwitterTrack.create(:created_utc => Time.now.to_i, :distance => 200)
    assert_equal TwitterTrack.total_distance, 300
  end

  test "can aggregate total duration with no data" do
    assert_equal TwitterTrack.total_duration, 0
  end

  test "can aggregate total duration with data" do
    TwitterTrack.create(:created_utc => Time.now.to_i, :duration => 100)
    TwitterTrack.create(:created_utc => Time.now.to_i, :duration => 200)
    assert_equal TwitterTrack.total_duration, 300
  end
end