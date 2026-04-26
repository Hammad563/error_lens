require_relative "lib/error_lens/version"

Gem::Specification.new do |spec|
  spec.name        = "error_lens"
  spec.version     = ErrorLens::VERSION
  spec.authors     = ["Hammad"]
  spec.email       = ["munirhammad786@gmail.com"]
  spec.homepage    = "https://github.com/hammad563/error_lens"
  spec.summary     = "Self-hosted error tracking for Rails and Sidekiq"
  spec.description = "A mountable Rails engine that captures, groups, and displays application errors with full context — request params, backtraces, and Sidekiq job details."
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri"    => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri"   => "#{spec.homepage}/blob/main/CHANGELOG.md"
  }

  spec.required_ruby_version = ">= 2.7.0"

  spec.files = Dir[
    "lib/**/*",
    "app/**/*",
    "config/**/*",
    "*.md",
    "*.gemspec"
  ]

  spec.add_dependency "rails", ">= 6.0"
end
