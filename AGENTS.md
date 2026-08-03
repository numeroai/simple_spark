# Project Overview

This is Numero's fork of the `simple_spark` gem (upstream: `jaymcaliley/simple_spark`) — a public, thin Ruby client for SparkPost's REST API v1, built on Excon.

## Structure

- `lib/simple_spark.rb` — require manifest; every endpoint file must be required here.
- `lib/simple_spark/client.rb` — HTTP core (Excon) plus one accessor method per endpoint.
- `lib/simple_spark/endpoints/*.rb` — one class per SparkPost API area.
- `lib/simple_spark/exceptions.rb` — exceptions auto-mapped from HTTP status codes.
- `lib/simple_spark/version.rb` — bump in any PR that changes `lib/` (patch for additive changes).
- `spec/` — RSpec unit tests.

## Architecture Facts

- `Client#call(method:, path:, body_values:, query_values:, extract_results:)` is the single HTTP entry point. `extract_results` defaults to true and unwraps SparkPost's standard `results` response envelope.
- Auth is the raw API key in the `Authorization` header (no `Bearer` prefix); subaccounts via the `X-MSYS-SUBACCOUNT` header. Endpoints never touch auth.
- Non-2xx responses raise classes from `Exceptions` (`BadRequest`, `ThrottleLimitExceeded`, `GatewayTimeoutExceeded`, etc.) — endpoints do not rescue or validate; let API errors surface.

## Adding an Endpoint

Register it in all three places: the `lib/simple_spark/endpoints/<name>.rb` class, an accessor method in `Client`, and a `require` in `lib/simple_spark.rb`.

Endpoint idiom (see `endpoints/suppression_list.rb`):
- `attr_accessor :client`, `initialize(client)`.
- Thin methods that call `@client.call(...)` — no client-side input validation.
- `@client.url_encode(...)` for any value interpolated into a path.
- YARD comments with an `@note` link to the SparkPost API docs (or a note when the endpoint is undocumented).
- Update the README's endpoint section with a short usage snippet.

## Testing

- RSpec: `bundle install && rake spec` (default rake task), or `rspec spec/path/to/file_spec.rb`.
- Unit tests only — stub `Client#call`; no network calls, no WebMock/VCR.
- Modify ENV in specs via `with_modified_env` (climate_control helper in `spec_helper.rb`).
- GitHub Actions runs RSpec for pull requests; run `rake spec` locally before pushing.

## PRs and Git

- Name branches `<github-handle>/kebab-case-branch`.
- PR titles are a concise Title Case summary.
- Keep changes additive and backward-compatible for public consumers.
