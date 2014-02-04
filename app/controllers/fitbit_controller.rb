class FitbitController < ApplicationController

  def index
    oauth_key = OauthKey.where(provider: 'fitbit').last
    options = {
      consumer_key: ENV["FITBIT_KEY"],
      consumer_secret: ENV["FITBIT_SECRET"],
      token: oauth_key.token,
      secret: oauth_key.token_secret,
    }
    client = Fitgem::Client.new(options)
    range_options = { base_date: 7.days.ago, period: '1w' }
    activity = client.data_by_time_range('/activities/tracker/steps', range_options)
    client.intraday_time_series({resource: :steps, date: 7.days.ago, detailLevel: "15min" })
    render json: activity
  end

  def show
    HardWorker.perform_async('bob', 10)
    render json: 'abc'
  end
  
  def poll
    Mapping.find_each do |mapping|
	  fitbit_options = {
        consumer_key: ENV["FITBIT_KEY"],
		consumer_secret: ENV["FITBIT_SECRET"],
		token: mapping.fitbit_token,
		secret: mapping.fitbit_token_secret,
      }
      fitbit_client = Fitgem::Client.new(options);
      range_options = { base_date: 1.days.ago, period: 'today' }
      steps = client.data_by_time_range('/activities/log/steps', range_options)
      sleep = client.data_by_time_range('/sleep/minutesAsleep', range_options)
		
      quanto_options = {
        consumer_key: ENV["QUANTO_KEY"],
        consumer_secret: ENV["QUANTO_SECRET"],
        access_token: mapping.quanto_access_token
      }
      quanto_client = Quanto::Client.new(options);
      quanto_client.record_metric(steps[:"activities-log-steps"][0][:value], 'steps');
      quanto_client.record_metric(sleep[:"sleep-minutesAsleep"][0][:value]/60.0, 'sleep'); #in hours
	end	
  end

end
