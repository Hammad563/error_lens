module ErrorLens
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue => e
      request = ActionDispatch::Request.new(env)
      event = build_event(e, request)
      ErrorLens::Processor.enqueue(event)
      raise e
    end

    private

    def extract_headers(request)
      request.headers.env
             .select { |k, _| k.start_with?("HTTP_") }
             .transform_keys { |k| k.sub("HTTP_", "").split("_").map(&:capitalize).join("-") }
    end

    def build_event(e, request)
      {
        exception_class:   e.class.name,
        exception_message: e.message,
        backtrace:         e.backtrace,
        occurred_at:       Time.current,
        source:            "web",
        environment:       Rails.env,

        request_id:        request.request_id,
        url:               request.url,
        http_method:       request.method,
        parameters:        request.filtered_parameters,
        user_agent:        request.user_agent,
        ip_address:        request.remote_ip,
        forwarded_for:     request.headers["X-Forwarded-For"],
        request_headers:   extract_headers(request),
        cause_class:       e.cause&.class&.name,
        cause_message:     e.cause&.message,

        job_class:         nil,
        job_args:          nil,
        job_id:            nil,
        queue:             nil
      }
    end
  end
end