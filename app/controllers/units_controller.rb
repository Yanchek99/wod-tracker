class UnitsController < ApplicationController
  # GET /measurements/:measurement_id/units.json
  def index
    @units = Metric.units(params[:measurement_id])
    render json: @units, status: :ok
  end
end
