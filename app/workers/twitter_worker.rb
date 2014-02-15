class TwitterWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
 
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV["TWITTER_KEY"]
      config.consumer_secret = ENV["TWITTER_SECRET"]
      config.access_token = mapping.api_key.token
      config.access_token_secret = mapping.api_key.token_secret
    end

    count = 0

    tweets = client.user_timeline(client.verify_credentials[:screen_name])
    
    tweets.each do |tweet|
      if Date.parse(tweet.created_at.to_s) === Date.today
        count+=1
      end
    end

    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_TWITTER_KEY"], ENV["QUANTO_TWITTER_SECRET"],
                                access_token: quanto_key.token)
    quanto_client.record_entry(count, :tweets)
  end

  def self.record_all
    Mapping.twitter.find_each { |mapping| TwitterWorker.perform_async(mapping.id) }
  end

end
