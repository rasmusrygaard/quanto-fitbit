require 'quanto'

class ManualInputController < ApplicationController

  protect_from_forgery :except => [:create]
  respond_to :json

  def create
    post_options = {
      date: params[:date],
    }

    mapping = Mapping.manual.last

    if mapping.nil?
      render json: "key not found", status: 422
      return
    end

    quanto_key = mapping.quanto_key
    client = Quanto::Client.new(ENV["QUANTO_MANUAL_KEY"], ENV["QUANTO_MANUAL_SECRET"], access_token: quanto_key.token)
    client.record_entry(params[:value], params[:metric_type], post_options)
    render json: "OK", status: 200
  end

end
