source 'https://rubygems.org'

# Specify your gem's dependencies in pact.gemspec
gemspec

if ENV['X_PACT_DEVELOPMENT']
  gem 'pact-support', path: '../pact-support'
end

gem 'pact-support', git: "https://github.com/joinhandshake/pact-support", ref: '0fa46bdaf27382a9eb86c9dfbcbca44d7b5e742c'