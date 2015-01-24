require 'fileutils'
require 'support/integration_spec_support'

describe "The pact-mock-service control server command line interface", mri_only: true do

  include Pact::ControlServerTestSupport

  before :all do
    @pid = start_control 1234, '--ssl'
  end

  it "responds to an OPTIONS request for a non administration request" do
    response = setup_interaction 1234
    puts response.body unless response.status == 200
    expect(response.status).to eq 200
    mock_service_port = URI(response.headers['X-Pact-Mock-Service-Location']).port
    puts "Started on #{mock_service_port}"
    response = wait_until_server_started_on_ssl mock_service_port
    expect(response.status).to eq 200
  end

  after :all do
    kill_server @pid
  end
end
