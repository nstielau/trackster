class TrackAggregator
  attr :result

  def self.reduce
<<-EOS
    function(month_year, values_array) {
      var total_distance = 0;
      var total_duration = 0;
      var max_max_speed = 0;
      var num_tracks = 0;
      values_array.forEach(function(f) {
        total_distance += f.distance;
        total_duration += (f.duration * 1);
        if (f.max_speed > max_max_speed) {
          max_max_speed = f.max_speed;
        }
        num_tracks += f.track_count;
      });
      return {user_id: values_array[0].user_id, year: values_array[0].year, month: values_array[0].month, day: values_array[0].day, distance: total_distance, duration: total_duration, max_speed: max_max_speed, track_count: num_tracks, interval: values_array[0].interval};
    }
EOS
  end

  def self.collection
    MongoMapper.database.collection("tracks")
  end

  def self.aggregate_collection
    MongoMapper.database.collection("track_aggregates")
  end

  def initialize(opts = {})
    options = {
      'value.interval' => nil,
      'value.user_id' => nil
    }
    opts.each_pair{|k,v| options["value.#{k}"] = v}
    @result = self.class.aggregate_collection.find(options).map{|x| x["value"]}
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
      // Now with user_id
      emit("totals-" + "-user" + this.user_id, {user_id: this.user_id, year: null, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: null});
      emit(year + "-user" + this.user_id, {user_id: this.user_id, year: year, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'year'});
      emit(year + "-" + month + "-user" + this.user_id, {user_id: this.user_id, year: year, month: date.getMonth(), day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'month'});
      emit(year + "-" + month + "-" + day + "-user" + this.user_id, {user_id: this.user_id, year: year, month: date.getMonth(), day: day, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'day'});
    }
EOS
    self.collection.map_reduce(map, self.reduce, :out => self.aggregate_collection.name)
  end
end