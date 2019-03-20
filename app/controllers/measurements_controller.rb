class MeasurementsController < ApplicationController
  # GET /measurements.json
  def index
    @measurements = Metric.measurements.keys
    render json: @measurements, status: :ok
  end
end
