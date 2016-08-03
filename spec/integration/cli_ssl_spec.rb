require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface, with SSL", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    @pid = start_server 4343, '--ssl', false
  end

  it "should respond with SSL" do
    wait_until_server_started 4343, true
  end

  it "sets the X-Pact-Mock-Service-Location header with https" do
    wait_until_server_started 4343, true
    response = connect_via_ssl 4343
    expect(response.headers['X-Pact-Mock-Service-Location']).to eq 'https://0.0.0.0:4343'
  end

  after :all do
    kill_server @pid
  end
end
