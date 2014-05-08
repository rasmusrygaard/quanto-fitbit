class FacebookWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)

    begin
      graph = Koala::Facebook::API.new(mapping.api_key.token)
      friends = graph.get_connections("me", "friends")
      statuses = graph.get_connections("me", "statuses")
    rescue Koala::Facebook::AuthenticationError => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'koala_facebook')
      mapping.invalidate!
      return
    end

    today = Time.zone.now.to_date
    cur_page = statuses
    count = 0
    if !statuses.last.nil?
      while Date.parse(statuses.last["updated_time"]) === today && !cur_page.next_page.nil?
        cur_page = cur_page.next_page
        count += 25
      end
    end

    cur_page.each do |status|
      if Date.parse(status["updated_time"]) === today
        count += 1
      end
    end
    quanto_key = mapping.quanto_key

    begin
      quanto_client = Quanto::Client.new(ENV["QUANTO_FACEBOOK_KEY"], ENV["QUANTO_FACEBOOK_SECRET"],
                                access_token: quanto_key.token)
      quanto_client.record_entry(friends.count, :friends)
      quanto_client.record_entry(count, :statuses)

    rescue OAuth2::Error => e
      NewRelic::Agent.agent.error_collector.notice_error(e, metric: 'facebook')
      mapping.invalidate!
    end
  end

  def self.record_all
    Mapping.facebook.find_each { |mapping| FacebookWorker.perform_async(mapping.id) }
  end

end
