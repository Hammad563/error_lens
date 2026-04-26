module ErrorLens
  class SidekiqMiddleware
    def call(worker, job, queue)
      yield
    rescue => e
      ErrorLens::Processor.enqueue(build_event(e, job, queue))
      raise
    end

    private

    def build_event(e, job, queue)
      {
        exception_class:   e.class.name,
        exception_message: e.message,
        backtrace:         e.backtrace,
        occurred_at:       Time.current,
        source:            "sidekiq",
        environment:       Rails.env,
        cause_class:       e.cause&.class&.name,
        cause_message:     e.cause&.message,

        job_class:         job["class"],
        job_id:            job["jid"],
        job_args:          job["args"],
        queue:             queue,
        request_id:        job["jid"],

        url:               nil,
        http_method:       nil,
        parameters:        nil,
        user_agent:        nil,
        ip_address:        nil,
        forwarded_for:     nil
      }
    end
  end
end
