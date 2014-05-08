class InstagramSubscriptionController < ApplicationController

  def create

  end

  def index
    if params['hub.mode'] && params['hub.mode'] == 'subscribe'
      render json: params['hub.challenge'], status: 200
    else
      render json: "error", status: 400
  end

end
