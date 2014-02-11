# app/workers/hard_worker.rb
class FitbitWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
    return if mapping.quanto_key.nil? || mapping.api_key.nil?

    fitbit_options = {
      consumer_key: ENV["FITBIT_KEY"],
      consumer_secret: ENV["FITBIT_SECRET"],
      token: mapping.api_key.token,
      secret: mapping.api_key.token_secret,
    }

    fitbit_client = Fitgem::Client.new(fitbit_options)
    range_options = { base_date: 1.days.ago, period: 'today' }
    steps = fitbit_client.data_by_time_range('/activities/log/steps', range_options)
    sleep = fitbit_client.data_by_time_range('/sleep/minutesAsleep', range_options)

    begin
      quanto_client = Quanto::Client.new(ENV["QUANTO_FITBIT_KEY"], ENV["QUANTO_FITBIT_SECRET"],
                                         access_token: mapping.quanto_key.token)
      quanto_client.record_entry(steps["activities-log-steps"][0]['value'], :steps)
      quanto_client.record_entry(sleep["sleep-minutesAsleep"][0]['value'], :sleep)
    rescue OAuth2::Error => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'fitbit')
      maping.invalidate!
    end
  end

  def self.record_all
    Mapping.fitbit.find_each { |mapping| FitbitWorker.perform_async(mapping.id) }
  end
end
