require 'rspec'
require 'fakefs/spec_helpers'
require 'rspec'
require 'pact/support'
require 'webmock/rspec'
require 'support/factories'
require 'support/spec_support'

WebMock.disable_net_connect!(allow_localhost: true)

require './spec/support/active_support_if_configured'

RSpec.configure do | config |
  config.include(FakeFS::SpecHelpers, :fakefs => true)
end

