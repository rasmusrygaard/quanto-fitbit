class LastfmWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
    lastfm = Lastfm.new(ENV["LASTFM_KEY"], ENV["LASTFM_SECRET"])

    lastfm_key = mapping.api_key
    start_time = Time.zone.now.to_date.beginning_of_day.to_i
    recent_tracks = lastfm.user.get_recent_tracks(user: lastfm_key.uid, from: start_time, limit: 200)

    track_count = recent_tracks.present? ? recent_tracks.count : 0


    quanto_key = mapping.quanto_key
    begin
      quanto_client = Quanto::Client.new(ENV["QUANTO_LASTFM_KEY"], ENV["QUANTO_LASTFM_SECRET"],
                                         access_token: quanto_key.token)
      quanto_client.record_entry(10, :tracks)
    rescue OAuth2::Error => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'lastfm')
      mapping.invalidate!
    end
  end

  def self.record_all
    Mapping.lastfm.find_each { |mapping| LastfmWorker.perform_async(mapping.id) }
  end

end
