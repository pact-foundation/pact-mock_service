require 'rspec'
require 'fakefs/spec_helpers'
require 'rspec'
require 'pact/support'
require 'webmock/rspec'
require 'support/factories'
require 'support/spec_support'

WebMock.disable_net_connect!(allow_localhost: true)

require './spec/support/active_support_if_configured'

is_java = defined?(RUBY_PLATFORM) && RUBY_PLATFORM.downcase.include?('java')
# SSL test times out on Travis, but will run locally...
# Issue recorded here: https://github.com/bethesque/pact-mock_service/issues/59
# Need to fix...
is_travis = ENV['TRAVIS'] == 'true'

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)
  config.filter_run_excluding :mri_only => is_java
  config.filter_run_excluding :skip_travis => is_travis

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
