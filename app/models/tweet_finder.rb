require 'twitter'
require 'bitly'

class TweetFinder
  def self.reset_max_twitter_id
    Meta.get_instance.last_twitter_update = 0
    Meta.get_instance.save
  end

  def self.find_tweets
    max_id = Meta.get_instance.last_twitter_update.to_i
    puts "Finding tweets with an ID > #{max_id}"
    parsed_tweets = 0
    broken_tweets = 0
    results = Twitter::Search.new("#motionx").since(max_id).each do |r|
      puts "  Examiing tweet ##{r.id}: #{r.text}"
      max_id = r.id if r.id > max_id
      if matches = r.text.match(/http.*$/)
        Bitly.use_api_version_3
        begin
          long_url = Bitly.new(BITLY_USERNAME, BITLY_KEY).expand(matches[0]).long_url
          if long_url && long_url.match(/http:\/\/maps.google.com.*http:\/\/api.motionxlive.com.*/)
            puts "  Parsing #{long_url}"
            begin
              tt = TwitterTrack.create_from_kmz_url(long_url)
              parsed_tweets = parsed_tweets + 1
            rescue TrackError => e
              puts e.message
              broken_tweets = broken_tweets + 1
            end
            puts "  Done parsing #{tt}"
          else
            puts "  Skipping #{long_url}, it doesn't seem to be a motionx url"
          end
        rescue => e
          puts "Twitter Error: "
          puts e.inspect
          e.backtrace.each do |l|
            puts "  #{l}"
          end
        end
      end
    end
    Meta.get_instance.last_twitter_update = max_id
    Meta.get_instance.save
    puts "Done finding tweets.  #{parsed_tweets} ok, #{broken_tweets} bad.  Most recent tweet is #{Meta.get_instance.last_twitter_update}"
  end
end