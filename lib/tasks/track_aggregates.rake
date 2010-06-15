namespace :aggregates do
  desc "Aggregates the tracks stats"
  task :update  => :environment do
    Track.generate_aggregates
    TwitterTrack.generate_aggregates
  end
end
