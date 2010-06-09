namespace :twitter do
  desc "Updates tracks from twitter"
  task :update  => :environment do
    TweetFinder.find_tweets
  end
end
