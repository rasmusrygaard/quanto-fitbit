class InstagramWorker
  include Sidekiq::Worker

  def perform(mapping_id)
    mapping = Mapping.find(mapping_id)
    return if mapping.quanto_key.nil? || mapping.api_key.nil?

    client = Instagram.client(access_token: mapping.api_key.token)


    quanto_key = mapping.quanto_key
    quanto_client = Quanto::Client.new(ENV["QUANTO_INSTAGRAM_KEY"], ENV["QUANTO_INSTAGRAM_SECRET"],
                                access_token: mapping.quanto_key.token)

    user = client.user
    quanto_client.record_entry(user.counts.media, :photos)
    quanto_client.record_entry(user.counts.followed_by, :followers)
    quanto_client.record_entry(user.counts.follows, :following)
  end

  def self.record_all
    Mapping.instagram.find_each { |mapping| InstagramWorker.perform_async(mapping.id) }
  end

end
