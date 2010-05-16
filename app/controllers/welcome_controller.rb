class WelcomeController < ApplicationController
  def index
    @total_distance = current_user ? current_user.total_distance : nil
    @total_active_time = current_user ? current_user.total_active_time : nil
    @total_tracks = current_user ? current_user.tracks.size : nil
  end

  def help
  end
end