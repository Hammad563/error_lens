require "error_lens/version"
require "error_lens/configuration"
require "error_lens/processor"
require "error_lens/writer"
require "error_lens/middleware"

module ErrorLens
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset!
      @configuration = nil
    end
  end
end

require "error_lens/engine" if defined?(Rails)
