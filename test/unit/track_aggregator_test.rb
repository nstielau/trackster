require 'test_helper'

class TrackAggregatorTest < ActiveSupport::TestCase
  def setup
    Track.all.each {|t| t.destroy}
  end

  test "returns a hash with correct values" do
    Track.create(:distance => 10, :distance => 200)
    TrackAggregator.generate_aggregates
    agg = TrackAggregator.new().result
    assert_equal agg.first.class, OrderedHash
    assert agg.first.has_key? 'distance'
    assert agg.first.has_key? 'duration'
    assert agg.first.has_key? 'track_count'
  end

  test "ignores user if no user_id option is specified" do
    Track.create(:distance => 1, :user_id => 100)
    Track.create(:distance => 10, :user_id => 200)
    TrackAggregator.generate_aggregates
    agg = TrackAggregator.new().result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 11
  end

  test "limit to user if user_id option is specified" do
    Track.create(:distance => 1, :user_id => 100)
    Track.create(:distance => 10, :user_id => 200)
    TrackAggregator.generate_aggregates
    agg = TrackAggregator.new(:user_id => 100).result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 1
  end

  test "should return a single row if no interval is specified" do
    Track.create(:distance => 1, :user_id => 100, :created_utc => 10.days.ago.to_i)
    Track.create(:distance => 10, :user_id => 200, :created_utc => 2.days.ago.to_i)
    TrackAggregator.generate_aggregates
    agg = TrackAggregator.new().result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 11
  end

  test "should return multiple rows if a small interval is specified" do
    Track.create(:distance => 1, :user_id => 100, :created_utc => 10.days.ago.to_i)
    Track.create(:distance => 10, :user_id => 200, :created_utc => 2.days.ago.to_i)
    TrackAggregator.generate_aggregates
    agg = TrackAggregator.new(:interval => 'day').result
    assert_equal agg.size, 2
    assert_equal agg.select{|x| x['distance'] == 1}.size, 1
    assert_equal agg.select{|x| x['distance'] == 10}.size, 1
  end
  #test "returns all rows if no start_time is specified and not end_time is specified"
end