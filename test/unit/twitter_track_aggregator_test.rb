require 'test_helper'

class TwitterTrackAggregatorTest < ActiveSupport::TestCase
  def setup
    TwitterTrack.all.each {|t| t.destroy}
  end

  test "returns a hash with correct values" do
    TwitterTrack.create(:distance => 10, :distance => 200)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new().result
    assert_equal agg.first.class, OrderedHash
    assert agg.first.has_key? 'distance'
    assert agg.first.has_key? 'duration'
    assert agg.first.has_key? 'track_count'
  end

  test "ignores user if no user_id option is specified" do
    TwitterTrack.create(:distance => 1)
    TwitterTrack.create(:distance => 10, :user_id => 200)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new().result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 11
  end

  test "should return a single row if no interval is specified" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :user_id => 200, :created_utc => 2.days.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new().result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 11
  end

  test "should return multiple rows if a small interval is specified" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :user_id => 200, :created_utc => 2.days.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new(:interval => 'day').result
    assert_equal agg.size, 2
    assert_equal agg.select{|x| x['distance'] == 1}.size, 1
    assert_equal agg.select{|x| x['distance'] == 10}.size, 1
  end

  test "returns all rows if no start_time is specified and not end_time is specified" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :created_utc => 2.days.ago.to_i)
    TwitterTrack.create(:distance => 100, :created_utc => 2.years.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new().result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 111
  end

  test "returns all rows after start_time" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :created_utc => 2.days.ago.to_i)
    TwitterTrack.create(:distance => 100, :created_utc => 2.years.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new(:start_time => 1.month.ago, :interval => 'day').result
    assert_equal agg.size, 2
    assert_equal agg.map{|x| x['distance']}.sum, 11
  end

  test "returns all rows before end_time" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :created_utc => 2.days.ago.to_i)
    TwitterTrack.create(:distance => 100, :created_utc => 2.years.ago.to_i)
    TwitterTrack.create(:distance => 1000, :created_utc => 3.months.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new(:end_time => 1.month.ago, :interval => 'day').result
    assert_equal agg.size, 2
    assert_equal agg.map{|x| x['distance']}.sum, 1100
  end

  test "returns all rows between start_time and end_time" do
    TwitterTrack.create(:distance => 1, :created_utc => 10.days.ago.to_i)
    TwitterTrack.create(:distance => 10, :created_utc => 2.days.ago.to_i)
    TwitterTrack.create(:distance => 100, :created_utc => 2.years.ago.to_i)
    TwitterTrack.create(:distance => 1000, :created_utc => 3.months.ago.to_i)
    TwitterTrackAggregator.generate_aggregates
    agg = TwitterTrackAggregator.new(:start_time => 1.year.ago, :end_time => 1.month.ago, :interval => 'day').result
    assert_equal agg.size, 1
    assert_equal agg.first['distance'], 1000
  end
end