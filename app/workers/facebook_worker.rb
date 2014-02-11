class FacebookWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
 
	graph = Koala::Facebook::API.new(mapping.api_key.token)
	statuses = graph.get_connections("me", "statuses")
	
	statuses_count = 0
	likes_count = 0
	statuses[:data].each do |status|
      if(Date.parse(status[:updated_time]) === Date.today)
	    statuses++
        if(status[:likes].present?)
          likes += status[:likes].count
        end
      end
    end
	
    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_FACEBOOK_KEY"], ENV["QUANTO_FACEBOOK_SECRET"],
                                access_token: quanto_key.token)
    quanto_client.record_metric(statuses_count, :posts)
	quanto_client.record_metric(likes_count, :likes)
  end

  def self.record_all
    Mapping.facebook.find_each { |mapping| FacebookWorker.perform_async(mapping.id) }
  end

end
