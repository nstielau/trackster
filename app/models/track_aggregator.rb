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
      return {date: values_array[0].date, user_id: values_array[0].user_id, year: values_array[0].year, month: values_array[0].month, day: values_array[0].day, distance: total_distance, duration: total_duration, max_speed: max_max_speed, track_count: num_tracks, interval: values_array[0].interval};
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

    if start_date = opts.delete(:start_time)
      raise "Still don't make no sense" if opts[:interval].nil?
      date_string = "#{start_date.year}-#{sprintf('%02d', start_date.month)}-#{sprintf('%02d', start_date.day)}"
      options['value.date'] = {:$gte => date_string}
    end

    if end_date = opts.delete(:end_time)
      raise "Still don't make no sense" if opts[:interval].nil?
      date_string = "#{end_date.year}-#{sprintf('%02d', end_date.month)}-#{sprintf('%02d', end_date.day)}"
      options['value.date'] ||= {}
      options['value.date'] = options['value.date'].merge(:$lte => date_string)
    end

    opts.each_pair{|k,v| options["value.#{k}"] = v}

    # puts
    # puts "All"
    # self.class.aggregate_collection.find().map{|x| x["value"]}.each{|x| puts x.inspect}
    # puts "Options: #{options.inspect}"
    @result = self.class.aggregate_collection.find(options).map{|x| x["value"]}
  end

  def self.generate_aggregates
    map = <<-EOS
    function() {
      var date = new Date(this.created_utc * 1000);
      var year = date.getFullYear();
      var month = date.getMonth() + 1;
      month = (month + "").length == 1 ? ("0" + month) : month;
      var day = (date.getDate() + "").length == 1 ? ("0" + date.getDate()) : date.getDate();
      emit("totals", {date: '', year: null, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: null, user_id: null});
      emit(year, {date: year + "", year: year, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'year', user_id: null});
      emit(year + "-" + month, {date: year + "-" + month, year: year, month: date.getMonth(), day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'month', user_id: null});
      emit(year + "-" + month + "-" + day, {date: year + "-" + month + "-" + day, year: year, month: date.getMonth(), day: day, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'day', user_id: null});
      // Now with user_id
      emit("totals-" + "-user" + this.user_id, {date: '', user_id: this.user_id, year: null, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: null});
      emit(year + "-user" + this.user_id, {date: year + "", user_id: this.user_id, year: year, month: null, day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'year'});
      emit(year + "-" + month + "-user" + this.user_id, {date: year + "-" + month, user_id: this.user_id, year: year, month: date.getMonth(), day: null, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'month'});
      emit(year + "-" + month + "-" + day + "-user" + this.user_id, {date: year + "-" + month + "-" + day, user_id: this.user_id, year: year, month: date.getMonth(), day: day, distance: this.distance, duration: this.duration, max_speed: this.max_speed, track_count: 1, interval: 'day'});
    }
EOS
    self.collection.map_reduce(map, self.reduce, :out => self.aggregate_collection.name)
  end
end