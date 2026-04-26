require "rails/generators"
require "rails/generators/migration"

module ErrorLens
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Installs ErrorLens — copies migration, mounts engine, creates initializer"

      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def copy_migration
        migration_template(
          "create_error_lens_tables.rb.tt",
          "db/migrate/create_error_lens_tables.rb"
        )
      end

      def mount_engine
        route 'mount ErrorLens::Engine, at: "/error_lens"'
      end

      def create_initializer
        create_file "config/initializers/error_lens.rb", <<~RUBY
          ErrorLens.configure do |config|
            # Error classes to ignore — these will not be recorded
            # config.ignored_exceptions = %w[ActionController::RoutingError]

            # Parameter keys to filter from stored data
            # config.filter_parameters = %w[password token secret credit_card]
          end
        RUBY
      end

      def show_readme
        say ""
        say "ErrorLens installed!", :green
        say ""
        say "Next steps:", :bold
        say "  1. Run migrations:       bundle exec rails db:migrate"
        say "  2. Start your server and hit /error_lens"
        say "  3. To protect the route, wrap the mount in your auth constraint:"
        say ""
        say "     # Devise example:"
        say "     authenticate :user, ->(u) { u.admin? } do"
        say "       mount ErrorLens::Engine, at: \"/error_lens\""
        say "     end"
        say ""
      end
    end
  end
end
