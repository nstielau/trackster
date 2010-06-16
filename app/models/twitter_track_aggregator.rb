class TwitterTrackAggregator < TrackAggregator

  def self.collection
    MongoMapper.database.collection("twitter_tracks")
  end

  def self.aggregate_collection
    MongoMapper.database.collection("twittertrack_aggregates")
  end

  def self.generate_aggregates
    map = <<-EOS
    function() {
      var date = new Date(this.created_utc * 1000);
      var year = date.getFullYear();
      var month = date.getMonth();
      var day = date.getDate();
      emit("totals", {year: null, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: null, user_id: null});
      emit(year, {year: year, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'year', user_id: null});
      emit(year + "-" + month, {year: year, month: date.getMonth(), day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'month', user_id: null});
      emit(year + "-" + month + "-" + day, {year: year, month: date.getMonth(), day: day, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'day', user_id: null});
    }
EOS
    self.collection.map_reduce(map, self.reduce, :out => self.aggregate_collection.name)
  end
end