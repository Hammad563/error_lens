require 'digest'

module ErrorLens
  class Writer
    def self.write(event)
      fingerprint = generate_fingerprint(event[:exception_class], event[:backtrace])
      app_line = extract_app_line(event[:backtrace])

      group = ErrorLens::ErrorGroup.find_or_create_by!(fingerprint: fingerprint) do |g|
        g.error_class   = event[:exception_class]
        g.message       = event[:exception_message]
        g.first_seen_at = Time.current
        g.last_seen_at  = Time.current
        g.source        = event[:source]
        g.environment   = event[:environment]
        g.location      = app_line
      end

      group.increment!(:occurrences_count)
      group.update_columns(
        last_seen_at: Time.current,
        source:       event[:source],
        location:     app_line
      )

      ErrorLens::ErrorOccurrence.create!(
        error_group:  group,
        message:      event[:exception_message],
        backtrace:    event[:backtrace].to_json,
        source:       event[:source],
        environment:  event[:environment],
        occurred_at:  event[:occurred_at] || Time.current,

        # web
        request_id:   event[:request_id],
        url:          event[:url],
        http_method:  event[:http_method],
        parameters:   (event[:parameters] || {}).to_json,
        user_agent:      event[:user_agent],
        ip_address:      event[:ip_address],
        forwarded_for:   event[:forwarded_for],
        request_headers: (event[:request_headers] || {}).to_json,
        cause_class:     event[:cause_class],
        cause_message:   event[:cause_message],

        # sidekiq
        job_class:    event[:job_class],
        job_args:     (event[:job_args] || []).to_json,
        job_id:       event[:job_id],
        queue:        event[:queue]
      )
    rescue => e
      Rails.logger.error "[ErrorLens] Writer failed: #{e.message}" rescue nil
    end

    private

    def self.extract_app_line(backtrace)
      return nil if backtrace.nil? || backtrace.empty?
      backtrace.find { |line| line.start_with?(Rails.root.to_s) } || backtrace.first
    end

    def self.generate_fingerprint(exception_class, backtrace)
      app_line = extract_app_line(backtrace) || "unknown"
      Digest::MD5.hexdigest("#{exception_class}-#{app_line}")
    end
  end
end