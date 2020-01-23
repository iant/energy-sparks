module Amr
  class ProcessAmrReadingData
    def initialize(amr_data_feed_import_log)
      @amr_data_feed_import_log = amr_data_feed_import_log
    end

    def perform(valid_readings, warning_readings)
      DataFeedUpserter.new(valid_readings, @amr_data_feed_import_log).perform
      create_warnings(warning_readings) unless warning_readings.empty?
      @amr_data_feed_import_log
    end

    private


    def create_warnings(warnings)
      updated_warnings = warnings.map do |warning|
        {
          amr_data_feed_import_log_id: @amr_data_feed_import_log.id,
          warning_types: warning[:warnings].map { |warning_symbol| AmrReadingWarning::WARNINGS.key(warning_symbol.to_sym) },
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc,
          mpan_mprn: warning[:mpan_mprn],
          reading_date: warning[:reading_date],
          readings: warning[:readings]
         }
      end
      AmrReadingWarning.insert_all(updated_warnings)
    end
  end
end
