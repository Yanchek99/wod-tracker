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
    flash.now[:alert] = e.message
    render :new, status: :unprocessable_content
  end

  private

  def set_sugarwod_import
    @sugarwod_import = Current.user.sugarwod_imports.find(params.expect(:id))
  end
end
