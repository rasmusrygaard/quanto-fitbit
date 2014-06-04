class FitbitSubscriptionController < ApplicationController

  respond_to :json

  # Skip verification since POST comes from Fitbit.
  protect_from_forgery :except => :create

  def create
    # Parse the JSON response. This is ugly.
    updateRes = params[:updates].tempfile.read
    puts updateRes
    updates = ActiveSupport::JSON.decode(updateRes).map(&:symbolize_keys)
    puts updates.inspect

    # Build a mapping from mapping IDs to the range of dates we need to update.
    to_update = {}
    updates.each do |update|
      date = Date.parse(update[:date])
      if to_update.include?(update[:subscriptionId])
        dates = update[:subscriptionId]
        dates[:start_date] = [dates[:start_date], date].min
        dates[:end_date]   = [dates[:end_date], date].max
      else
        to_update[update[:subscriptionId]] = { start_date: date, end_date: date }
      end
    end

    to_update.each do |mapping_id, dates|
      FitbitSubscriptionWorker.perform_async(mapping_id, dates[:start_date], dates[:end_date])
    end

    render json: "ok", status: 200
  end


end
