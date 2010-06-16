class WelcomeController < ApplicationController
  def index
    @total_distance = current_user ? current_user.total_distance : nil
    @total_active_time = current_user ? current_user.total_active_time : nil
    @total_tracks = current_user ? current_user.tracks.size : nil

    @user_data = TrackAggregator.new({:user_id => current_user.id, :interval => 'day', :start_time => 1.month.ago}).result
  end

  def help
  end

  def twitter_dashboard
    @twitter_data = TwitterTrackAggregator.new({:interval => 'day', :start_time => 30.days.ago}).result
  end
end