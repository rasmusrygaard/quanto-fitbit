class MovesWorker
  include Sidekiq::Worker

  def perform(mapping_id, fetch_all=false)
    mapping = Mapping.find(mapping_id)

    client = Moves::Client.new(mapping.api_key.token)

    quanto_key = mapping.quanto_key
    begin
      quanto_client = Quanto::Client.new(ENV["QUANTO_MOVES_KEY"], ENV["QUANTO_MOVES_SECRET"],
                                access_token: quanto_key.token)

      activities = fetch_all ? client.daily_summary(from: 1.month.ago, to: Time.zone.now.to_date) : client.daily_summary
      return if activities.blank?
      activities.each do |activity_summary|

        opt = { date: Time.zone.parse(activity_summary['date']) }
        activity_summary['summary'].each do |summary|
          calories = summary['calories']
          distance = summary['distance']
          duration = summary['duration']

          case summary['activity']
          when 'walking'
            quanto_client.record_entry(duration / 60.0, :"Time Walking", opt) unless duration.nil?
            quanto_client.record_entry(calories, :"Calories Burned Walking", opt) unless calories.nil?
            quanto_client.record_entry(distance, :"Distance Walked", opt) unless distance.nil?
          when 'cycling'
            quanto_client.record_entry(duration / 60.0, :"Time Cycling", opt) unless duration.nil?
            quanto_client.record_entry(calories, :"Calories Burned Cycling", opt) unless calories.nil?
            quanto_client.record_entry(distance, :"Distance Cycling", opt) unless distance.nil?
          when 'transport'
            quanto_client.record_entry(duration / 60.0, :"Time Driving", opt) unless duration.nil?
            quanto_client.record_entry(distance / 1000.0, :"Distance Driven", opt) unless distance.nil?
          end
        end
      end

    rescue OAuth2::Error => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'moves')
      mapping.invalidate!
    end
  end

  def self.record_all
    Mapping.moves.find_each { |mapping| MovesWorker.perform_async(mapping.id) }
  end

end
