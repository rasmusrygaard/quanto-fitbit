class MovesWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
 
    client = Moves::Client.new(mapping.api_key.token)
	
    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_MOVES_KEY"], ENV["QUANTO_MOVES_SECRET"],
                                access_token: quanto_key.token)

    activities = client.daily_summary[0]["summary"]

    for activity in activities
      if activity["activity"] == "walking"
        walking = activity
      end
      if activity["activity"] == "cycling"
        cycling = activity
      end
    end

    if defined?(walking)
      quanto_client.record_entry(walking["duration"]/60.0, :"Time Walking");
      quanto_client.record_entry(walking["calories"], :"Calories Burned Walking");
    end
    if defined?(cycling)
      quanto_client.record_entry(cycling["duration"]/60.0, :"Time Cycling");
      quanto_client.record_entry(cycling["calories"], :"Calories Burned Cycling");
    end
  end


  def self.pull_from_date(mapping_id, date)
    mapping = Mapping.find(mapping_id)
 
    client = Moves::Client.new(mapping.api_key.token)
	
    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_MOVES_KEY"], ENV["QUANTO_MOVES_SECRET"],
                                access_token: quanto_key.token)

    activities = client.daily_summary(date.to_s)[0]["summary"]

    for activity in activities
      if activity["activity"] == "walking"
        walking = activity
      end
      if activity["activity"] == "cycling"
        cycling = activity
      end
    end

    if defined?(walking)
      quanto_client.record_entry(walking["duration"]/60.0, :"Time Walking");
      quanto_client.record_entry(walking["calories"], :"Calories Burned Walking");
    end
    if defined?(cycling)
      quanto_client.record_entry(cycling["duration"]/60.0, :"Time Cycling");
      quanto_client.record_entry(cycling["calories"], :"Calories Burned Cycling");
    end
  end

  def self.record_all
    Mapping.moves.find_each { |mapping| MovesWorker.perform_async(mapping.id) }
  end

  def self.pull_backlog
    for date in Date.parse("2014-02-20").upto(Date.today)
      Mapping.moves.find_each { |mapping| MovesWorker.pull_from_date(mapping.id, date) }
    end
  end

end
