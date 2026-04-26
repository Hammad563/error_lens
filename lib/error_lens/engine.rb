module ErrorLens
  class Engine < ::Rails::Engine
    isolate_namespace ErrorLens

    initializer "error_lens.middleware" do |app|
      app.middleware.use ErrorLens::Middleware
    end

    initializer "error_lens.sidekiq" do
      if defined?(Sidekiq)
        require "error_lens/sidekiq_middleware"
        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add ErrorLens::SidekiqMiddleware
          end
        end
      end
    end
  end
end