# app/workers/hard_worker.rb
class FitbitWorker
  include Sidekiq::Worker

  def perform(mapping_id, fetch_all=false)
    mapping = Mapping.find(mapping_id)
    return if mapping.quanto_key.nil? || mapping.api_key.nil?

    fitbit_options = {
      consumer_key: ENV["FITBIT_KEY"],
      consumer_secret: ENV["FITBIT_SECRET"],
      token: mapping.api_key.token,
      secret: mapping.api_key.token_secret,
    }

    fitbit_client = Fitgem::Client.new(fitbit_options)
    range_options = { base_date: fetch_all ? 2.years.ago : 1.days.ago, end_date: Date.today }
    steps = fitbit_client.data_by_time_range('/activities/log/steps', range_options)
    sleep = fitbit_client.data_by_time_range('/sleep/minutesAsleep', range_options)

    begin
      quanto_client = Quanto::Client.new(ENV["QUANTO_FITBIT_KEY"], ENV["QUANTO_FITBIT_SECRET"],
                                         access_token: mapping.quanto_key.token)

      # Log steps data
      if steps.present? && steps["activities-log-steps"].present?
        steps["activities-log-steps"].select { |s| s['value'] != 0 }. each do |step_data|
          quanto_client.record_entry(step_data['value'], :steps, date: step_data['dateTime'])
        end
      end

      # Log sleep data
      if sleep.present? && sleep["sleep-minutesAsleep"].present?
        sleep["sleep-minutesAsleep"].select { |s| s['value'] != 0 }.each do |sleep_data|
          quanto_client.record_entry(sleep_data['value'], :sleep, date: sleep_data['dateTime'])
        end
      end

    rescue OAuth2::Error => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'fitbit')
      mapping.invalidate!
    end
  end

  def self.record_all
    Mapping.fitbit.find_each { |mapping| FitbitWorker.perform_async(mapping.id) }
  end
end
