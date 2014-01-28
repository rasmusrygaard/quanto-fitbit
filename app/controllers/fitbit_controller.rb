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

end
