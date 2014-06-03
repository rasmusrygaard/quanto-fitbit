class InstagramSubscriptionController < ApplicationController

  respond_to :json

  # Skip verification since POST comes from Instagram.
  protect_from_forgery :except => :create

  def create
    # Can't verify request because heroku strips X header.
    # if Instagram.validate_update(params['_json'].to_json, headers)

    Instagram.process_subscription(params['_json'].to_json) do |handler|

      handler.on_user_changed do |user_id, data|
        key = OauthKey.instagram.where(uid: user_id.to_s).last
        mapping = Mapping.where(api_key: key).first
        InstagramWorker.perform_async(mapping.id)
      end

    end

    render json: "ok", status: 200
  end

  def index
    valid_params = Instagram.client.meet_challenge(params, ENV['INSTAGRAM_VERIFY_TOKEN'])
    render json: (valid_params || 'error')
  end

end
