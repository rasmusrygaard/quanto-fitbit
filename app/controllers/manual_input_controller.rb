require 'quanto'

class ManualInputController < ApplicationController

  protect_from_forgery :except => [:create]
  respond_to :json

  def create
    post_options = {
      date: params[:date],
    }

    begin
      client = Quanto::Client.new(ENV["QUANTO_MANUAL_KEY"], ENV["QUANTO_MANUAL_SECRET"], access_token: params[:access_token])
      client.record_entry(params[:value], params[:metric_type], post_options)
      render json: "OK", status: 200
    rescue OAuth2::Error => e
      render json: "error", status: 401
    end
  end

  def authenticate
    client = OAuth2::Client.new(ENV["QUANTO_MANUAL_KEY"], ENV["QUANTO_MANUAL_SECRET"], site: 'http://quanto.herokuapp.com')
    begin
      token = client.password.get_token(params[:email], params[:password])
      render json: { access_token: token.token }, status: 200
    rescue OAuth2::Error => e
      render json: "error", status: 401
    end
  end

end
