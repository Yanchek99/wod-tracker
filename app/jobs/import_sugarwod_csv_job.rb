class ImportSugarwodCsvJob < ApplicationJob
  queue_as :default

  def perform(sugarwod_import_id, rows)
    sugarwod_import = SugarwodImport.find(sugarwod_import_id)
    imported = 0
    already_imported = 0
    skipped_rows = []

    rows.each do |row|
      result = begin
        SugarwodImport::RowImporter.call(symbolize_row(row), user: sugarwod_import.user)
      rescue StandardError => e
        SugarwodImport::RowImporter::Result.new(status: :skipped, reason: e.message)
      end

      case result.status
      when :imported then imported += 1
      when :already_imported then already_imported += 1
      when :skipped then skipped_rows << { 'date' => row['date'], 'title' => row['title'], 'reason' => result.reason }
      end
    end

    sugarwod_import.update!(
      status: :completed, imported_count: imported, already_imported_count: already_imported,
      skipped_count: skipped_rows.size, skipped_rows: skipped_rows
    )
  end

  private

  def symbolize_row(row)
    {
      date: Date.strptime(row['date'], '%m/%d/%Y'), title: row['title'], description: row['description'],
      best_result_raw: row['best_result_raw'], best_result_display: row['best_result_display'],
      score_type: row['score_type'], barbell_lift: row['barbell_lift'], set_details: row['set_details'],
      notes: row['notes']
    }
  end
end
