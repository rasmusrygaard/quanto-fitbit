class LastfmWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
    lastfm = Lastfm.new(ENV["LASTFM_KEY"], ENV["LASTFM_SECRET"])

    lastfm_key = mapping.api_key
    start_time = Date.today.beginning_of_day.to_i
    recent_tracks = lastfm.user.get_recent_tracks(user: lastfm_key.uid, from: start_time, limit: 200)

    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_LASTFM_KEY"], ENV["QUANTO_LASTFM_SECRET"],
                                access_token: quanto_key.token)
    quanto_client.record_entry(recent_tracks.count, :tracks)
  end

  def self.record_all
    Mapping.lastfm.find_each { |mapping| LastfmWorker.perform_async(mapping.id) }
  end

end
