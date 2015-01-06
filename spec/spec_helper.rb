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

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)
  config.filter_run_excluding :mri_only => is_java

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
