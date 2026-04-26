module ErrorLens
  class Processor
    QUEUE_LIMIT = 500

    def self.enqueue(event)
      instance.enqueue(event)
    end

    def self.instance
      @instance ||= new
    end

    def initialize
      @queue = SizedQueue.new(QUEUE_LIMIT)
      @thread = nil
      @mutex = Mutex.new
    end

    def enqueue(event)
      ensure_running
      @queue.push(event, true)
    rescue ThreadError      # Queue is full, drop the event
    rescue
    end

    private

    def ensure_running
      return if @thread&.alive? 

      @mutex.synchronize do
        return if @thread&.alive?

        @thread = Thread.new { run }
        @thread.name = "error_lens"
      end
    end

    def run
      loop do
        event = @queue.pop
        ErrorLens::Writer.write(event)
      rescue => e
        Rails.logger.error "[ErrorLens] #{e.message}" rescue nil
      end
    end
  end
end