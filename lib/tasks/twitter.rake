namespace :twitter do
  desc "Updates tracks from twitter"
  task :update  => :environment do
    puts "Finding tweets"
    TweetFinder.find_tweets
    puts "Done finding tweets"
  end
end
