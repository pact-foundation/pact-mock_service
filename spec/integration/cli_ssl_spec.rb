require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service command line interface, with SSL", mri_only: true do

  include Pact::IntegrationTestSupport

  before :all do
    @pid = start_server 4343, '--ssl', false
  end

  it "should respond with SSL" do
    response = wait_until_server_started_on_ssl 4343
    expect(response.status).to eq 200
  end

  after :each do
    kill_server @pid
  end
end
