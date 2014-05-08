class InstagramSubscriptionController < ApplicationController

  def create
    render text: "not authorized", status: 401 unless Instagram.validate_update(request.body, headers)

    Instagram.process_subscription(params[:body]) do |handler|

      handler.on_user_changed do |user_id, data|
        key = OauthKey.instagram.where(uid: user_id.to_s)
        mapping = Mapping.where(api_key: key).first
        InstagramWorker.perform_async(mapping.id)
      end

    end
  end

  def index
    valid_params = Instagram.client.meet_challenge(params)
    render json: valid_params if valid_params
  end

end
