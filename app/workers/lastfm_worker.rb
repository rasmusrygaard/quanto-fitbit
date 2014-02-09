class LastfmWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
    lastfm = Lastfm.new(ENV["LASTFM_KEY"], ENV["LASTFM_SECRET"])

    lastfm_key = mapping.api_key
    start_time = Date.today.beginning_of_day.to_i
    recent_tracks = lastfm.user.get_recent_tracks(user: lastfm_key.uid, from: start_time, limit: 200)

    quanto_key = mapping.quanto_key
    client = Quanto::Client.new(ENV["QUANTO_FITBIT_KEY"], ENV["QUANTO_FITBIT_SECRET"],
                                access_token: quanto_key.token)
    client.record_metric(recent_tracks.count, :tracks)
  end
end
