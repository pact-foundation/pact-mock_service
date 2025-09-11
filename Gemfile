source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem 'pact-support', path: '../pact-support'
end
gem "pact-support", github: "pact-foundation/pact-support", branch: "fix/json_load_regression"