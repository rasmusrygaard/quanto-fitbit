class FitbitController < ApplicationController

  def index
    oauth_key = OauthKey.last
    options = {
      consumer_key: 'c42a6a7099f54e0ab9146fa355604a14',
      consumer_secret: '01371805cee6429da70c5dab1f3d1705',
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
