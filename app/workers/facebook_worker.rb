class FacebookWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
 
    graph = Koala::Facebook::API.new(mapping.api_key.token)
    friends = graph.get_connections("me", "friends")
	
    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_FACEBOOK_KEY"], ENV["QUANTO_FACEBOOK_SECRET"],
                                access_token: quanto_key.token)
    quanto_client.record_metric(friends.count, :friends)
  end

  def self.record_all
    Mapping.facebook.find_each { |mapping| FacebookWorker.perform_async(mapping.id) }
  end

end
