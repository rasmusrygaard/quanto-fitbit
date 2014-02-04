require 'quanto'

class ManualInputController < ApplicationController

  protect_from_forgery :except => [:create]
  respond_to :json

  def create
    post_options = {
      date: params[:date],
    }
    quanto_key = OauthKey.quanto.where(uid: params[:user_id].to_s).first

    if quanto_key.nil?
      render json: "key not found", status: 422
      return
    end

    client = Quanto::Client.new(ENV["QUANTO_KEY"], ENV["QUANTO_SECRET"], access_token: quanto_key.token)
    client.record_metric(params[:value], params[:metric_type], post_options)
    render json: "OK", status: 200
  end

end
