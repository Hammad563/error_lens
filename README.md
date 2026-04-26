# ErrorLens

Self-hosted error tracking for Rails apps, built as a mountable engine. No separate service, no Redis, no SaaS bill — just two database tables in your existing Postgres.

Captures web request errors and Sidekiq job failures, groups them by type and location, and gives you a clean UI to browse, search, and resolve them.

## Features

- Groups errors by class and backtrace location (fingerprinting)
- Captures full context: request params, headers, backtrace, IP, user agent
- Sidekiq job support: job class, queue, job ID, arguments
- Search errors by class name or message
- Resolve / reopen / delete error groups
- Paginated occurrence history with newer/older navigation
- Zero performance impact — captures are queued in-process and written asynchronously
- No external dependencies beyond Rails and ActiveRecord

## Installation

Add to your Gemfile:

```ruby
gem "error_lens", path: "vendor/error_lens"
```

Or once published to RubyGems:

```ruby
gem "error_lens"
```

Run the installer:

```bash
bundle install
rails generate error_lens:install
rails db:migrate
```

## Mounting

In `config/routes.rb`:

```ruby
mount ErrorLens::Engine, at: "/admin/error_lens"
```

ErrorLens has no built-in authentication — mount it behind your existing auth constraint:

```ruby
mount ErrorLens::Engine, at: "/admin/error_lens", constraints: AdminConstraint.new
```

## Configuration

In an initializer (`config/initializers/error_lens.rb`):

```ruby
ErrorLens.configure do |config|
  # Exception classes to ignore entirely
  config.ignored_exceptions = %w[
    ActionController::RoutingError
    ActiveRecord::RecordNotFound
  ]

  # Parameters to filter from captured request data
  config.filter_parameters = %w[password token secret credit_card]
end
```

## Purging old data

Occurrences older than 60 days can be purged via a Rake task or a scheduled job:

```ruby
ErrorLens::ErrorOccurrence.purge_older_than(60)
```

Run it from a cron or a Sidekiq scheduled job to keep the table from growing unbounded. Error groups are kept even after their occurrences are purged.

## How it works

1. `ErrorLens::Middleware` wraps every Rack request. On exception it builds an event hash and pushes it to an in-memory `SizedQueue` (capped at 500), then re-raises so your app handles the response normally.
2. A background thread (`ErrorLens::Processor`) drains the queue and calls `ErrorLens::Writer`.
3. `Writer` computes an MD5 fingerprint from the exception class and first app backtrace line, upserts the `error_lens_groups` record, and inserts a new `error_lens_occurrences` row.
4. Sidekiq errors follow the same path via `ErrorLens::SidekiqMiddleware`.

The request thread only does a queue push — the DB write never blocks your request.

## License

MIT
