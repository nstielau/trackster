class WelcomeController < ApplicationController
  def index
    @total_distance = current_user ? current_user.total_distance : nil
    @total_active_time = current_user ? current_user.total_active_time : nil
    @total_tracks = current_user ? current_user.tracks.size : nil
  end

  def help
  end

  def twitter_dashboard
    @interval = 'day'
    options = {"value.interval" => @interval}
    options['value.month'] = Time.now.month-1 if @interval == 'day'
    options['value.year'] = Time.now.year if @interval != 'year'
    @twitter_data = MongoMapper.database.collection("twittertrack_aggregates").find(options).map{|x| x["value"]}
  end
end