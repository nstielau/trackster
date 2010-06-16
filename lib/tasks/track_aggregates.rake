namespace :aggregates do
  desc "Aggregates the tracks stats"
  task :update  => :environment do
    TrackAggregator.generate_aggregates
    TwitterTrackAggregator.generate_aggregates
  end
end
