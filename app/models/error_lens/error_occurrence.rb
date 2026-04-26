module ErrorLens
  class ErrorOccurrence < ActiveRecord::Base
    self.table_name = "error_lens_occurrences"

    belongs_to :error_group,
               class_name:  "ErrorLens::ErrorGroup",
               foreign_key: :error_group_id

    scope :recent, -> { order(occurred_at: :desc) }

    def self.purge_older_than(days = 60)
      where("occurred_at < ?", days.days.ago).delete_all
    end

    def parsed_backtrace
      JSON.parse(backtrace || "[]")
    rescue JSON::ParserError
      []
    end

    def parsed_parameters
      JSON.parse(parameters || "{}")
    rescue JSON::ParserError
      {}
    end

    def parsed_job_args
      JSON.parse(job_args || "[]")
    rescue JSON::ParserError
      []
    end

    def parsed_request_headers
      JSON.parse(request_headers || "{}")
    rescue JSON::ParserError
      {}
    end

    def app_backtrace
      parsed_backtrace.select { |line| line.start_with?(Rails.root.to_s) }
    end

    def web?
      source == "web"
    end

    def sidekiq?
      source == "sidekiq"
    end
  end
end
