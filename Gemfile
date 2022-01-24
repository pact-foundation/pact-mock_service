source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem 'pact-support', path: '../pact-support'
end

gem 'pact-support', git: "https://github.com/Benjaminpjacobs/pact-support", ref: 'cfa90871707c28d8ec46f323fbaf0c3e61a54066'
