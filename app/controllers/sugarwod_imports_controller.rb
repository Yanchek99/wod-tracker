class SugarwodImportsController < ApplicationController
  before_action :set_sugarwod_import, only: [:show]

  def show; end
  def new; end

  def create
    rows = SugarwodImport::CsvParser.call(params.expect(:file).read)
    sugarwod_import = Current.user.sugarwod_imports.create!(status: :pending)
    ImportSugarwodCsvJob.perform_later(sugarwod_import.id, rows)
    redirect_to sugarwod_import_path(sugarwod_import)
  rescue SugarwodImport::CsvParser::InvalidHeadersError => e
    render_upload_error(e.message)
  rescue CSV::MalformedCSVError => e
    render_upload_error("Could not read that file as CSV: #{e.message}")
  end

  private

  def render_upload_error(message)
    flash.now[:alert] = message
    render :new, status: :unprocessable_content
  end

  def set_sugarwod_import
    @sugarwod_import = Current.user.sugarwod_imports.find(params.expect(:id))
  end
end
