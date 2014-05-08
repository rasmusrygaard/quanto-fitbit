class InstagramSubscriptionController < ApplicationController

  def create
    Instagram.process_subscription(params[:body]) do |handler|

      handler.on_user_changed do |user_id, data|
        key = OauthKey.instagram.where(uid: user_id.to_s)
        user = User.by_instagram_id(user_id)
        @client = Instagram.client(:access_token => _access_token_for_user(user))
        latest_media = @client.user_recent_media[0]
        user.media.create_with_hash(latest_media)
      end

    end
  end

  def index
    valid_params = Instagram.client.meet_challenge(params)
    render json: valid_params if valid_params
  end

end
