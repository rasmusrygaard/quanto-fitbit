class MovesWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
 
    client = Moves::Client.new(mapping.api_key.token)
	
    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_MOVES_KEY"], ENV["QUANTO_MOVES_SECRET"],
                                access_token: quanto_key.token)

    activities = client.daily_summary[:summary]

    for activity in activities
      if activity[:activity] == "walking"
        walking = activity
      end
      if activity[:activity] == "cycling"
        cycling = activity
      end
    end

    quanto_client.record_entry(walking[:duration]/60.0, :"Time Walking");
    quanto_client.record_entry(walking[:calories], :"Calories Burned Walking");
    quanto_client.record_entry(cycling[:duration]/60.0, :"Time Cycling");
    quanto_client.record_entry(cycling[:calories], :"Calories Burned Cycling");
  end

  def self.record_all
    Mapping.moves.find_each { |mapping| MovesWorker.perform_async(mapping.id) }
  end

end
