source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem 'pact-support', path: '../pact-support'
end

gem 'pact-support', git: "https://github.com/Benjaminpjacobs/pact-support", ref: 'b688d0f87871a96bfdae3ba810bf5b40d4344d14'