source 'https://rubygems.org'

# Specify the gem's runtime dependencies in simple_spark.gemspec.
gemspec

# CI pins runtime dependencies to specific ranges to verify the bounds the
# gemspec advertises, e.g. JSON_VERSION='~> 2.7.0' EXCON_VERSION='~> 0.109.0'.
gem 'json', ENV['JSON_VERSION'] unless ENV['JSON_VERSION'].to_s.empty?
gem 'excon', ENV['EXCON_VERSION'] unless ENV['EXCON_VERSION'].to_s.empty?

group :development, :test do
  gem 'rake', '~> 13.4'
  gem 'rspec', '~> 3.13'
  gem 'rspec-nc', '~> 0.3'
  gem 'climate_control', '~> 1.2'
end

group :development do
  gem 'guard', '~> 2.20'
  gem 'guard-rspec', '~> 4.7'
  gem 'pry', '~> 0.16'
  gem 'pry-remote', '~> 0.1'
end
